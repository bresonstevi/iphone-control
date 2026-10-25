# Demo shot list (30–45 seconds)

Stevi records the real clip and commits it as `docs/demo.gif` (or `docs/demo.mp4` if a GIF is too heavy). This file is the shot list only. There is no stand-in image or video in the repo.

Use a **spare test iPhone** with no personal, health, or financial accounts. Keep the author's UDID, team id, and Apple ID off camera. Crop the terminal so `policy.json` values are not readable.

On-screen target: a page you control whose visible control says **Buy** and does nothing expensive. A local HTML file opened in Safari is enough (`<button>Buy</button>`). Do not film the App Store, Wallet, a bank, Messages, Health, or a signed-in store.

Say the words out loud or as on-screen captions. Total runtime about 40 seconds.

## 0:00–0:05 — Title

Stick Figure Tech for Dads. Spare iPhone, USB cable, Mac terminal in `~/iphone-control`. Caption: "Safety-first spare iPhone control."

## 0:05–0:12 — Phone is up

```bash
./bridge/iphone status
```

Show `ready: true`. If it is not ready, cut this take. Do not film a troubleshooting session.

## 0:12–0:22 — Buy is refused

The test page is visible, with the Buy control on screen. Run:

```bash
./bridge/iphone tap-label "Buy"
echo "exit=$?"
```

Hold on **exit code 3** and the refusal line. Do not pass `--approved` in this shot. The phone must not activate the control.

## 0:22–0:33 — One approval

Caption, spoken by the owner: "Yes. Tap Buy once on the test page."

Then one command:

```bash
./bridge/iphone tap-label "Buy" --approved
```

Show that this single approved tap runs. Do not approve a second action. Do not show a real purchase.

## 0:33–0:42 — The log

```bash
tail -n 2 logs/actions.jsonl
```

The two lines should read as a blocked Buy tap (`"result":"blocked"`) and then the approved tap. Scroll so typed secrets are absent. This log is the point of the clip: the refusal is recorded, and the approval is recorded.

## 0:42–0:45 — End card

`github.com/bresonstevi/iphone-control` · MIT · spare phone only.

## Capture notes

- 30–45 seconds, one take if you can, no background music with lyrics.
- Terminal font large enough to read `exit=3` on a phone screen.
- Save the master as `docs/demo.gif`. The README slot at the top points at that path.
- If a real account, notification, or health card appears, stop and do not use that take.
