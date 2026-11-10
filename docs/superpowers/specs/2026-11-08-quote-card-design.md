# Quote card design

Approved by Abdhi through Maspur on 2026-11-08. This slice is fixture-backed. It does not fetch a tweet.

## Output

- One horizontal card, aspect ratio 3:2.
- Logical canvas: 600 by 400 points.
- Export scale: 3.
- Pixel size: exactly 1800 by 1200.
- Preview and export use one clean card view, with the same text, attribution, and layout.
- Preview scales that view to the available width.
- Export renders that view only. The sheet, fixture banner, picker, pager, and buttons are not in the image.

## Content

- The card shows the chosen excerpt, author display name, @handle, and source URL.
- No avatar image, so the app does not load a network photo.
- Fixture identity is labeled outside the card: sample data, not a live tweet.
- Four fixtures: normal, long, emoji (including a ZWJ sequence), and Arabic RTL.
- The existing Highlight Tweet action still sets the excerpt from a manual selection. The app does not rewrite the selection.
- A selection is kept only when it occurs inside the fixture source on Swift character boundaries.

## Fit

- Typography sizes are fixed. The card does not shrink the font and does not truncate with an ellipsis.
- If the excerpt or the attribution does not fit, the preview shows an explicit overflow state and tells the user to choose a shorter excerpt.
- Share and Save stay disabled until the content fits, including while fit is still being measured and while an export is in flight.
- Empty or whitespace-only excerpts cannot be exported.

## Export

- Rendering runs on the main actor through SwiftUI `ImageRenderer`, with proposed size 600 by 400 and scale 3.
- Do not snapshot the window with `drawHierarchy`.
- The rendered pixel size is checked. A mismatch is a visible error, not a successful save.
- Share uses the system share sheet only. Cancel is not an error. On iPad, the sheet uses a popover anchor.
- Save still writes a PNG to Photos. Denied permission and save failure appear in the UI.
- A newer excerpt, fixture, or failed generation discards a stale render before share or save.

## Out of scope

- URL fetch, X API, provider switching, backend, AI, and new packages.
- Activating `XClient` or `XAPI`.
- A full editor, bookmarks, or automatic WhatsApp posting.
