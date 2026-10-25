# Security

iphone-control is a safety-first CLI for a **spare test iPhone** plugged into your Mac. Use a phone that does not hold real accounts.

## Spare phone, no PHI

Keep personal, health, and financial data off that phone. Screenshots and the element tree copy whatever is on the screen, and `logs/actions.jsonl` records commands. Do not put protected health information (PHI), account numbers, passwords, recovery codes, or session logs into a GitHub issue, pull request, or chat.

`shots/`, `logs/`, and a filled-in `bridge/policy.json` (UDID, team id) stay on your Mac. They are git-ignored on purpose.

## Report privately

Report a vulnerability through [GitHub private vulnerability reporting](https://github.com/bresonstevi/iphone-control/security/advisories/new).

Include what you ran, the exit code, and a description of the impact. Leave out screenshots, logs, and device identifiers. If you need a non-security question answered, use a public issue with the same privacy rule, or the contact address published on [stickfiguretech.com](https://stickfiguretech.com).

## What the code refuses

Taps, label taps, and typing are blocked (exit code 3) for risky words, for a tap whose element cannot be identified, and for long digit runs or secure fields, unless that exact command is passed `--approved`. App launch is allowlisted. Those checks are a backstop. Review `logs/actions.jsonl` yourself. The word list is not a complete catalog of harmful actions.

The bridge does not send telemetry.
