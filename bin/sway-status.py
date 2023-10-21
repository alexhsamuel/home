import datetime
import json
from   pathlib import Path
import subprocess
import sys
import time
import zoneinfo

#-------------------------------------------------------------------------------

COMMON = {
    # "border": "#000000",
    # "border_top": 3,
    # "border_bottom": 0,
}

def read_assignments(path):
    with open(path, "r") as file:
        return dict( l.strip().split("=", 1) for l in file )


def get_tz():
    try:
        file = open("/etc/localtime", "rb")
    except FileNotFoundError:
        return datetime.timezone.utc
    else:
        with file:
            return zoneinfo.ZoneInfo.from_file(file)


def get_time():
    now = datetime.datetime.now().astimezone(get_tz())
    return {
        **COMMON,
        "full_text": format(now, "%Y-%m-%d %H:%M:%S"),
    }


_count = 0

def get_count():
    global _count
    _count += 1
    return {
        **COMMON,
        "full_text": f"{_count}",
        "background": "#ffffff",
        "color": "#000000",
    }


def get_battery(ps="BAT1"):
    try:
        battery = read_assignments(Path("/sys/class/power_supply") / ps / "uevent")
    except FileNotFoundError:
        return dict(COMMON)
    battery = { n[13 :]: v for n, v in battery.items() }
    charge  = int(battery["CHARGE_NOW"])
    full    = int(battery["CHARGE_FULL"])
    curr    = int(battery["CURRENT_NOW"])

    frac        = charge / full

    # Time to dis/charge.
    if curr != 0:
        secs        = int(3600 * (full - charge) / curr)
        mins, secs  = divmod(secs, 60)
        hours, mins = divmod(mins, 60)
        time        = f"{hours}:{mins:02d}:{secs:02d}"
    else:
        time        = "??:??:??"

    symbol = {
        # "Charging": "\N{electric plug}",
        # "Discharging": "\N{battery}",
        "Charging": "[CHG]",
        "Discharging": "[DIS]",
    }.get(battery["STATUS"], "X")

    return {
        **COMMON,
        "full_text": f"{symbol} {frac * 100:3.0f}% {time}",
        "background": "#004060",
        # "border": "#004060",
        # "border_left": 2,
        # "border_right": 2,
        "separator": False,
    }


def get_wifi():
    """
    Returns the SSID of the current wireless network.

    Requires package `wireless_tools`.
    """
    try:
        net = subprocess.check_output(["/usr/bin/iwgetid", "-r"], text=True).strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        return COMMON
    return {
        **COMMON,
        "full_text": f"SSID: {net or 'none'}",
        "separator": True,
    }


json.dump(
    {
        "version": 1,
    },
    sys.stdout
)
print("\n")
print("[")
while True:
    json.dump(
        [
            get_wifi(),
            get_battery(),
            # get_count(),
            get_time(),
        ],
        sys.stdout
    )
    sys.stdout.write(",")
    sys.stdout.flush()
    time.sleep(0.1)


