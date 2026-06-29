"""
Spoolman Filament-Usage Sync

A standalone background monitor for printers WITHOUT native Moonraker
[spoolman] support (e.g. Elegoo and other vendor Moonraker builds).

It polls Moonraker's job history for finished prints and deducts the filament
each one used from the active spool in a (typically centralized) Spoolman
instance. Moonraker records `filament_used` in millimetres for every finished
job — including partial usage when a print is cancelled — so no Moonraker
modification is required.

Active-spool selection is intentionally manual: whoever loads a spool sets it
once (via the MCP `set_active_spool` tool or by editing the state file), and
every subsequent print is charged to that spool until it is changed. The same
helper functions here back the MCP tools, so both processes agree on which
spool is active.

IMPORTANT: Do NOT run this alongside native Moonraker [spoolman] tracking —
both would deduct the same filament and double-count it. The monitor checks for
the native integration at startup and refuses to run if it is present.

Run standalone:  python spoolman_sync.py
"""
import asyncio
import json
import logging
import os
import tempfile
import time
from typing import Optional

import aiohttp

import config
from moonraker import get_client

logger = logging.getLogger("spoolman_sync")


# =============================================================================
# Local active-spool state (shared with the MCP tools in tools/spoolman.py)
# =============================================================================
# Two separate files are used so the MCP server process (which writes the
# active spool) and the monitor process (which writes its progress marker)
# never clobber each other's field.

def _read_json(path: str) -> dict:
    """Read a small JSON state file, returning {} if missing or unreadable."""
    try:
        with open(path, "r") as f:
            return json.load(f)
    except (FileNotFoundError, ValueError):
        return {}


def _write_json_atomic(path: str, data: dict) -> None:
    """Write JSON atomically so a concurrent reader never sees a partial file."""
    os.makedirs(os.path.dirname(path), exist_ok=True)
    fd, tmp = tempfile.mkstemp(dir=os.path.dirname(path), suffix=".tmp")
    try:
        with os.fdopen(fd, "w") as f:
            json.dump(data, f)
        os.replace(tmp, path)
    except Exception:
        if os.path.exists(tmp):
            os.remove(tmp)
        raise


def get_active_spool_id() -> Optional[int]:
    """Return the locally-tracked active spool id, or None if unset."""
    return _read_json(config.SPOOLMAN_ACTIVE_SPOOL_FILE).get("spool_id")


def set_active_spool_id(spool_id: int) -> None:
    """Set the locally-tracked active spool. Subsequent prints charge to it."""
    _write_json_atomic(config.SPOOLMAN_ACTIVE_SPOOL_FILE, {"spool_id": spool_id})


def clear_active_spool_id() -> None:
    """Clear the locally-tracked active spool. Prints will not be deducted."""
    _write_json_atomic(config.SPOOLMAN_ACTIVE_SPOOL_FILE, {"spool_id": None})


def _load_sync_state() -> dict:
    return _read_json(config.SPOOLMAN_SYNC_STATE_FILE)


def _save_sync_state(state: dict) -> None:
    _write_json_atomic(config.SPOOLMAN_SYNC_STATE_FILE, state)


# =============================================================================
# Spoolman / Moonraker helpers
# =============================================================================

async def _native_spoolman_present(client) -> bool:
    """True if Moonraker's native [spoolman] component is responding.

    If it is, this monitor must not run — the native integration already
    deducts filament and running both would double-count usage.
    """
    res = await client.get("/server/spoolman/status")
    return "error" not in res


async def _deduct_filament(session: aiohttp.ClientSession, spool_id: int, length_mm: float) -> dict:
    """Deduct a length of filament (mm) from a Spoolman spool.

    Spoolman converts the length to weight using the spool's filament density
    and diameter, so we only send the length Moonraker reported.
    """
    url = f"{config.SPOOLMAN_URL}/api/v1/spool/{spool_id}/use"
    async with session.put(url, json={"use_length": length_mm}) as resp:
        resp.raise_for_status()
        return await resp.json()


async def _process_job(session: aiohttp.ClientSession, job: dict) -> None:
    """Charge one finished print's filament usage to the active spool."""
    job_id = job.get("job_id")
    filament_mm = job.get("filament_used") or 0
    status = job.get("status", "unknown")

    if filament_mm <= 0:
        logger.info("Job %s (%s) used no filament; nothing to deduct", job_id, status)
        return

    spool_id = get_active_spool_id()
    if spool_id is None:
        logger.warning(
            "Job %s (%s) used %.1f mm but no active spool is set — skipping. "
            "Set one with the set_active_spool tool to track future prints.",
            job_id, status, filament_mm,
        )
        return

    try:
        await _deduct_filament(session, spool_id, filament_mm)
        logger.info(
            "Job %s (%s): deducted %.1f mm from spool %d",
            job_id, status, filament_mm, spool_id,
        )
    except aiohttp.ClientResponseError as e:
        if e.status == 404:
            logger.error(
                "Active spool %d not found in Spoolman (deleted?). "
                "Job %s usage of %.1f mm was NOT recorded.",
                spool_id, job_id, filament_mm,
            )
        else:
            raise


# =============================================================================
# Monitor loop
# =============================================================================

async def run_monitor() -> None:
    if not getattr(config, "SPOOLMAN_SYNC_ENABLED", False):
        logger.info("SPOOLMAN_SYNC_ENABLED is false — sync monitor disabled, exiting.")
        return

    interval = getattr(config, "SPOOLMAN_SYNC_POLL_INTERVAL", 30)
    client = get_client()

    logger.info("Spoolman sync monitor starting (Spoolman: %s, poll: %ss)",
                config.SPOOLMAN_URL, interval)

    # Refuse to run if native Moonraker spoolman tracking is active.
    if await _native_spoolman_present(client):
        logger.error(
            "Native Moonraker [spoolman] integration detected. Refusing to run to "
            "avoid double-counting filament. Disable SPOOLMAN_SYNC_ENABLED, or remove "
            "[spoolman] from moonraker.conf if you want klipper-mcp to do the tracking."
        )
        return

    # On first run, only count prints from now on — never retroactively deduct
    # the printer's entire existing history.
    state = _load_sync_state()
    if "last_end_time" not in state:
        state["last_end_time"] = time.time()
        _save_sync_state(state)
        logger.info("First run — tracking prints finishing after now.")

    async with aiohttp.ClientSession() as session:
        while True:
            try:
                hist = await client.get_print_history(limit=50)
                jobs = hist.get("result", {}).get("jobs", [])

                # Finished jobs (have an end_time) newer than the last we processed.
                last_end = state["last_end_time"]
                finished = [
                    j for j in jobs
                    if j.get("end_time") and j["end_time"] > last_end
                ]
                finished.sort(key=lambda j: j["end_time"])

                for job in finished:
                    await _process_job(session, job)
                    state["last_end_time"] = max(state["last_end_time"], job["end_time"])
                    _save_sync_state(state)

            except aiohttp.ClientError as e:
                logger.warning("Spoolman/Moonraker request failed: %s", e)
            except Exception:
                logger.exception("Unexpected error in sync loop")

            await asyncio.sleep(interval)


def main() -> None:
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(name)s %(levelname)s %(message)s",
    )
    try:
        asyncio.run(run_monitor())
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()
