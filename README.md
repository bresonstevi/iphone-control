# iphone-control

**Safety-first spare iPhone control for busy dads and parents.** A small Mac CLI that lets a coding agent tap, type, and read a spare test phone, and refuses send, buy, pay, and delete until you say yes for that exact action.

Stick Figure Tech for Dads. The family brand is [stickfiguretech.com](https://stickfiguretech.com). This repository is the spare-phone bridge for a parent at the Mac.

[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Python 3.9+](https://img.shields.io/badge/python-3.9%2B-blue.svg)](https://www.python.org/)
[![tests](https://github.com/bresonstevi/iphone-control/actions/workflows/tests.yml/badge.svg)](https://github.com/bresonstevi/iphone-control/actions/workflows/tests.yml)

<!-- When docs/demo.gif is in the repo, replace the note below with:
![Demo: Buy tap refused (exit 3), one approved tap, then the action log](docs/demo.gif)
-->

> **Demo:** Stevi will drop the real 30–45s clip at `docs/demo.gif`. Shot list: [docs/DEMO.md](docs/DEMO.md) (refuse a Buy tap with exit code 3, approve once, show the log). No stand-in GIF is committed.

`iphone-control` is the canonical repo. If you use Grok Build, install this repository. The sibling repo `iphone-control-grok-build` is a separate project; leave it where it is. The Grok notes from that README are in [Using with Grok Build](#using-with-grok-build) below.

Safety is enforced in code, not only in docs:

- Taps, label taps, and typing are refused (exit code 3) when the target or text matches a risky word (send, buy, pay, delete, confirm, sign out, and more), unless `--approved` is passed.
- A tap whose target element cannot be identified is refused unless `--approved`.
- Typing 13+ digit runs (card-like numbers) or into password fields is refused unless `--approved`.
- Only apps on an allowlist can be launched (unless `--force`).
- Every command, including blocked and failed ones, is appended to an action log.

Python 3 standard library only. No pip installs. No telemetry.

## Install

Clone it to the path `policy.json` already uses, then run the installer. It is safe to run again. It chmods the scripts, reports `python3`, `xcodebuild`, and `iproxy` when they are present, and clones [WebDriverAgent](https://github.com/appium/WebDriverAgent) into the checkout when `WebDriverAgent/` is missing. It does not edit `policy.json`, sign the phone, or tap anything.

```bash
git clone https://github.com/bresonstevi/iphone-control.git ~/iphone-control
bash ~/iphone-control/scripts/install.sh
```

### Ask an agent to install it

Paste this into Grok Build, Cursor, Codex, or Claude Code on the Mac the spare iPhone is plugged into:

```text
Set up iphone-control (https://github.com/bresonstevi/iphone-control) on this Mac so you can drive my spare test iPhone. This is Stick Figure Tech for Dads. AGENTS.md wins over this prompt.

1. Clone https://github.com/bresonstevi/iphone-control.git to ~/iphone-control if it is not already there. Read scripts/install.sh, then run `bash scripts/install.sh` from the repo root. Re-run it if the checkout is already present. The script only chmods scripts, checks for python3, xcodebuild, and iproxy, and clones WebDriverAgent when that directory is missing.
2. Help me fill bridge/policy.json from THIS Mac and THIS phone only: YOUR_DEVICE_UDID, YOUR_TEAM_ID, wda_bundle_id, iproxy_bin, and the PLACEHOLDER.app1 / app2 / app3 allowlist keys. The file in git contains placeholders, not the author's device. Never copy a UDID, team id, or bundle id from the author, from GitHub issues, or from another machine. Never commit the filled-in policy.json.
3. Do not edit bridge/iphone.py, bridge/iphone, bridge/resign.sh, or the risky_words list unless I explicitly ask for a bridge change in this conversation.
4. These steps are mine: sign in to an Apple ID in Xcode, turn on Developer Mode, tap Trust on the developer profile, and unlock the phone. Stop, tell me exactly what to tap, and wait until I say it is done. Never ask me for a password, passcode, or verification code.
5. After I say the profile is trusted and the phone is unlocked, run `./bridge/resign.sh` only if I asked you to sign WebDriverAgent. Then run `./bridge/iphone start` and `./bridge/iphone status`.
6. Before any tap, type, or swipe, follow AGENTS.md (status first, screenshot or tree before the action). If a command exits 3, stop and ask. Never pass `--approved` or `--force` on your own.
```

## Setup

You need:

- A Mac with Xcode, signed in to an Apple ID. A free Personal Team works; signing then expires every 7 days.
- A spare iPhone with Developer Mode on (Settings, Privacy & Security, Developer Mode), connected by USB and trusted by the Mac.
- `iproxy` from libimobiledevice (`brew install libimobiledevice`).
- `/usr/bin/python3` (macOS system Python 3.9+ is fine). `bridge/iphone` calls that path specifically.
- A checkout of WebDriverAgent (the install script clones it).

After `scripts/install.sh`:

1. Find your own values. Device UDID: `xcrun xctrace list devices` or `idevice_id -l`. Team ID: Xcode, Settings, Accounts. Choose a bundle id you control, such as `com.yourname.WebDriverAgentRunner`.
2. Edit `bridge/policy.json`. Replace `YOUR_DEVICE_UDID`, `YOUR_TEAM_ID`, and the `com.example` bundle id. Set `iproxy_bin` from `which iproxy`. Replace `PLACEHOLDER.app1`, `PLACEHOLDER.app2`, and `PLACEHOLDER.app3` with real bundle ids, or delete those keys.
3. If the checkout is not `~/iphone-control`, point `wda_dir`, `derived_data`, the log paths, `shots_dir`, and `actions_log` at this checkout. The install script prints that reminder.
4. Build and sign WebDriverAgent: `./bridge/resign.sh`.
5. On the phone, trust the developer profile: Settings, General, VPN & Device Management, your Apple Development profile, Trust.
6. Unlock the phone, then:

   ```bash
   ./bridge/iphone start
   ./bridge/iphone status
   ./bridge/iphone screenshot
   ```

7. Optional: `ln -s ~/iphone-control/bridge/iphone /usr/local/bin/iphone`.

Run the safety tests with `cd bridge && python3 -m unittest test_tap_guard`. Full command reference: [bridge/README.md](bridge/README.md).

## Safety

- Use a spare test phone only. Leave your personal phone and any work phone that holds real accounts unplugged.
- Keep personal, health, and financial data off the spare phone. Screenshots and element trees capture whatever is on screen.
- Nothing gets sent, posted, bought, deleted, or signed in or out without the owner's explicit approval for that exact action. `--approved` and `--force` only record a yes that a human already gave.
- An agent must not edit `policy.json`, the bridge code, or the logs as part of a phone task.
- The bridge never kills processes and has no unlock, lock, or password actions.
- Screenshots (`shots/`) and the action log (`logs/`) can contain private information. They are git-ignored; keep it that way.
- The code blocks are a backstop, not a permission system. Review `logs/actions.jsonl` regularly.

Risky words (blocked without `--approved`): send, buy, pay, submit, purchase, order, delete, checkout, confirm, transfer, post, publish, erase, reset, remove, sign out, log out, subscribe, donate, place order, book.

Private vulnerability reports: [SECURITY.md](SECURITY.md).

## Using with Grok Build

iphone-control is the canonical repository for this bridge, including for Grok Build. Clone and install this repo. Do not switch installs over to `bresonstevi/iphone-control-grok-build`, and do not archive that sibling from here; it is a different repository. The Grok section that lived on its README is the list below.

This repo works with the Grok CLI (Grok Build) as the agent that operates the phone or maintains the bridge.

1. Install the Grok CLI and sign in, following the official Grok Build docs at [x.ai/cli](https://x.ai/cli) ([source](https://github.com/xai-org/grok-build)).
2. Start it from the repo root (`cd ~/iphone-control && grok`) so it picks up `AGENTS.md`, which contains the hard rules and the required workflow (status first, screenshot or tree before every action, prefer `tap-label`).
3. Optional: make the rules global by copying `AGENTS.md` into a user-level skill or rules file (for example a skill named `iphone`), so any Grok session can drive the phone safely without being in this directory.
4. Keep phone tasks and code tasks separate. For a phone task, ask Grok to use only `bridge/iphone` commands. For a change to the bridge itself, ask for it explicitly, then review the diff and run `python3 -m unittest test_tap_guard` in `bridge/` before using it.
5. Run Grok in a mode where shell commands need your approval, and say no to any command that passes `--approved` or `--force` unless you just approved that exact action.
6. Read the screenshot files Grok saves (it can open PNGs) and check `logs/actions.jsonl` after a session.

There is no MCP server in this repo. Point the agent at `AGENTS.md` and `bridge/iphone`.

## Layout

```
iphone-control/
  AGENTS.md                 rules and workflow for coding agents
  README.md                 this page
  SECURITY.md               spare phone, no PHI, private reports
  CONTRIBUTING.md           tests and what not to commit
  scripts/install.sh        chmod, tool checks, clone WebDriverAgent
  docs/DEMO.md              shot list for the demo clip
  docs/demo.gif             real clip, added by Stevi (not in git yet)
  apps/README.md            optional per-app notes (git-ignored by default)
  bridge/
    iphone                  bash wrapper (symlink-safe)
    iphone.py               the bridge CLI
    policy.json             app allowlist, risky words, device config
    resign.sh               rebuild and re-sign WDA (build-for-testing)
    test_tap_guard.py       unit tests for the safety checks
    README.md               full command reference
  .github/workflows/tests.yml
```

## Commands

| Command | What it does |
| --- | --- |
| `iphone status` | WDA ready?, iOS version, iproxy/xcodebuild running, session id. Read-only. |
| `iphone start` | Starts iproxy and the WDA run if needed, waits up to 90 s. Never kills anything. |
| `iphone screenshot` | Saves a PNG and prints the path. Read-only. |
| `iphone tree` | Lists visible elements. Read-only. |
| `iphone tap` / `tap-label` | Tap by point or by label. Refused on risky words. |
| `iphone type` | Types into the focused field. Refused on risky words, long digit runs, and password fields. |
| `iphone swipe` / `home` | Drag gesture, or press Home (does not lock). |
| `iphone launch` / `terminate` | Launch an allowlisted app, or close an app. |
| `iphone apps` | Prints the allowlist. No phone call. |

Exit codes: 0 ok, 1 runtime error, 2 usage error, 3 blocked by policy. Details, flags, and examples: [bridge/README.md](bridge/README.md).

## Re-signing

With a free Personal Team, the WebDriverAgent install expires after 7 days. Run `./bridge/resign.sh`, stop the old WDA `xcodebuild` run yourself, then `./bridge/iphone start`.

## License

MIT. See [LICENSE](LICENSE). No analytics.
