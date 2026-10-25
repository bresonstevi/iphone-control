#!/usr/bin/env bash
# Idempotent local setup for iphone-control.
# Chmods the CLI scripts, reports python3 / xcodebuild / iproxy when they
# are on PATH, and clones WebDriverAgent next to bridge/ when that
# directory is missing. Does not edit policy.json, sign, tap, or start
# iproxy / xcodebuild.
#
# Safe to run again. A failed or foreign WebDriverAgent path is left in
# place (this script never deletes it).

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WDA_URL="https://github.com/appium/WebDriverAgent.git"
WDA_DIR="${ROOT}/WebDriverAgent"
NEED_ATTENTION=0

say() {
  printf '%s\n' "$*"
}

note_missing() {
  NEED_ATTENTION=1
}

for rel in bridge/iphone bridge/resign.sh bridge/policy.json; do
  if [[ ! -f "${ROOT}/${rel}" ]]; then
    say "missing ${ROOT}/${rel}"
    say "Run this script from a checkout of bresonstevi/iphone-control."
    exit 1
  fi
done

chmod +x "${ROOT}/bridge/iphone" "${ROOT}/bridge/resign.sh" "${ROOT}/scripts/install.sh"

say "iphone-control install"
say "repo: ${ROOT}"
say ""
say "Checks (reported when the tool is present; nothing is installed for you):"

if path="$(command -v python3 2>/dev/null)"; then
  pyver="$(python3 -c 'import sys; print("%d.%d" % sys.version_info[:2])')"
  say "ok       python3 ${pyver}: ${path}"
  major="${pyver%%.*}"
  minor="${pyver#*.}"
  if [[ "${major}" -lt 3 ]] || { [[ "${major}" -eq 3 ]] && [[ "${minor}" -lt 9 ]]; }; then
    say "         Python 3.9 or newer is required."
    note_missing
  fi
else
  say "missing  python3"
  say "         Install Python 3.9 or newer. The safety tests and resign.sh use python3."
  note_missing
fi

if [[ -x /usr/bin/python3 ]]; then
  sysver="$(/usr/bin/python3 -c 'import sys; print("%d.%d" % sys.version_info[:2])')"
  say "ok       /usr/bin/python3 ${sysver} (bridge/iphone execs this path)"
else
  say "missing  /usr/bin/python3"
  say "         bridge/iphone calls /usr/bin/python3 specifically."
  say "         On a Mac, install Xcode or the Command Line Tools."
  note_missing
fi

if path="$(command -v xcodebuild 2>/dev/null)"; then
  say "ok       xcodebuild: ${path}"
else
  say "missing  xcodebuild"
  say "         Install Xcode from the App Store and open it once so the license is accepted."
  note_missing
fi

if path="$(command -v iproxy 2>/dev/null)"; then
  say "ok       iproxy: ${path}"
  say "         Put that path in bridge/policy.json device.iproxy_bin if it differs."
else
  say "missing  iproxy"
  say "         brew install libimobiledevice"
  say "         Then set device.iproxy_bin to the path from: which iproxy"
  note_missing
fi

say ""
if [[ -d "${WDA_DIR}/.git" ]]; then
  say "ok       WebDriverAgent already cloned: ${WDA_DIR}"
elif [[ -e "${WDA_DIR}" ]]; then
  say "leave    ${WDA_DIR} exists and is not a git checkout. Not deleting it."
  say "         Move it aside yourself, then run scripts/install.sh again to clone upstream."
  note_missing
else
  say "clone    ${WDA_URL}"
  say "         into ${WDA_DIR} (shallow). This matches policy.json when the repo is ~/iphone-control."
  GIT_TERMINAL_PROMPT=0 git clone --depth 1 "${WDA_URL}" "${WDA_DIR}"
  say "ok       WebDriverAgent cloned"
fi

say ""
say "Next: edit bridge/policy.json on this Mac. Git holds placeholders only."
say "Do not copy a UDID, team id, or bundle id from the repo author, from issues, or from another machine."
say "This script does not write policy.json and does not print a UDID or team id that is already filled in."
say ""

if command -v python3 >/dev/null 2>&1; then
  python3 - "${ROOT}/bridge/policy.json" <<'PY'
import json
import os
import sys

policy_path = sys.argv[1]
with open(policy_path, "r", encoding="utf-8") as fh:
    policy = json.load(fh)

device = policy.get("device") or {}
apps = policy.get("allowed_apps") or {}

def placeholder(value):
    text = "" if value is None else str(value)
    upper = text.upper()
    return (
        text.strip() == ""
        or "YOUR_" in upper
        or "PLACEHOLDER" in upper
        or "com.example" in text
    )

rows = [
    ("device.udid", device.get("udid"), "xcrun xctrace list devices   or   idevice_id -l", True),
    ("device.team_id", device.get("team_id"), "Xcode > Settings > Accounts, or the Team ID on the WebDriverAgent target", True),
    ("device.wda_bundle_id", device.get("wda_bundle_id"), "Use a reverse-DNS id you control, such as com.yourname.WebDriverAgentRunner", False),
    ("device.iproxy_bin", device.get("iproxy_bin"), "which iproxy", False),
]
for label, value, how, hide_when_set in rows:
    if label == "device.iproxy_bin":
        path = "" if value is None else str(value)
        expanded = os.path.expanduser(path)
        if path.strip() == "" or not os.path.exists(expanded):
            shown = path if path.strip() else "(empty)"
            sys.stdout.write("todo     %s is %s and is not on this machine\n" % (label, shown))
            sys.stdout.write("         %s\n" % how)
            continue
    if placeholder(value):
        shown = value if value not in (None, "") else "(empty)"
        sys.stdout.write("todo     %s is still %s\n" % (label, shown))
        sys.stdout.write("         %s\n" % how)
    elif hide_when_set:
        sys.stdout.write("set      %s (value not printed)\n" % label)
    else:
        sys.stdout.write("set      %s is %s\n" % (label, value))

pending = []
ready = 0
for key in apps:
    if str(key).startswith("PLACEHOLDER"):
        pending.append(key)
    else:
        ready += 1
if pending:
    sys.stdout.write("todo     allowed_apps still has %s\n" % ", ".join(pending))
    sys.stdout.write("         Replace each key with a real bundle id, or delete the key.\n")
sys.stdout.write("info     %d allowlisted app(s) besides placeholders\n" % ready)
PY
else
  say "todo     device.udid (YOUR_DEVICE_UDID), device.team_id (YOUR_TEAM_ID)"
  say "todo     device.wda_bundle_id (replace com.example), device.iproxy_bin"
  say "todo     allowed_apps keys PLACEHOLDER.app1, PLACEHOLDER.app2, PLACEHOLDER.app3"
fi

home_dir="${HOME:-}"
if [[ -n "${home_dir}" && "${ROOT}" != "${home_dir}/iphone-control" ]]; then
  say ""
  say "path     This checkout is ${ROOT}"
  say "         policy.json device paths still assume ~/iphone-control"
  say "         (wda_dir, derived_data, wda_run_log, wda_build_log, iproxy_log, shots_dir, actions_log)."
  say "         Move the checkout to ~/iphone-control, or point those paths at ${ROOT}."
fi

say ""
say "After you plug in a spare phone, unlock it, and trust the developer profile:"
say "  ./bridge/resign.sh"
say "  ./bridge/iphone start"
say "  ./bridge/iphone status"
say "Safety tests, no phone:"
say "  (cd ${ROOT}/bridge && python3 -m unittest test_tap_guard)"
say ""
say "install.sh does not sign, tap, type, launch an app, or pass --approved / --force."

if [[ "${NEED_ATTENTION}" -ne 0 ]]; then
  say ""
  say "Finished. Something above is still missing. Re-run scripts/install.sh after it is fixed."
else
  say ""
  say "Finished. Tool checks passed and WebDriverAgent is present. Policy placeholders may still need you."
fi
exit 0
