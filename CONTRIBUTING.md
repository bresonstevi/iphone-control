# Contributing

iphone-control is the safety-first spare-iPhone CLI from Stick Figure Tech for Dads. Changes should keep that CLI boring and strict.

## Before you open a pull request

1. Use a spare test phone in any manual check. Keep personal, health, and financial data off it and out of the diff.
2. Run the safety tests from `bridge/`:

   ```bash
   python3 -m unittest test_tap_guard
   ```

3. Do not commit `shots/`, `logs/`, `WebDriverAgent/`, `DerivedData/`, provisioning profiles, or a `policy.json` that contains a real UDID or team id. The copy in git stays on `YOUR_DEVICE_UDID` / `YOUR_TEAM_ID` / `PLACEHOLDER.app*`.
4. Leave bridge safety behavior alone unless the change is the point of the PR. If you do change `bridge/iphone.py`, extend `bridge/test_tap_guard.py` in the same PR.

## Docs and packaging

`README.md` is the public front door. `bridge/README.md` is the command reference. `AGENTS.md` is the rule file an agent should follow while the phone is in use. `scripts/install.sh` may be re-run; it must not edit `policy.json` or start signing.

## Reports

Security issues go through private vulnerability reporting. See `SECURITY.md`. Public issues are fine for bugs and ideas when they contain no screenshots, logs, or device identifiers.

MIT licensed. See `LICENSE`.
