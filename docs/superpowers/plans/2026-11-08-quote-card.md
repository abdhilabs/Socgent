# Quote card implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Show one fixture-backed 3:2 quote card, and share or save it only when the chosen excerpt fits at a fixed size, as a 1800 by 1200 PNG.

**Architecture:** `QuoteCardCanvas` is the only card view. A pure measurer decides fit from the same widths and font sizes. `TweetDetailReducer` keeps the excerpt, generation, and export gate. `ImageRenderer` runs on the main actor behind a dependency. Photos and the share sheet run only after the returned image matches 1800 by 1200 and the generation is still current.

**Tech Stack:** SwiftUI, The Composable Architecture 1.23, Swift Testing, existing Photos usage. No new packages.

## Global Constraints

- Canvas: 600 by 400 points, scale 3, pixels 1800 by 1200.
- One shared card for preview and export. Preview only scales it.
- Fixed typography. Overflow disables Share and Save. No clipping and no font shrink.
- Fixtures are labeled outside the image. No network and no `XClient` calls.
- Share is the system sheet. Cancel is not an error. iPad uses a popover anchor.
- Photos denial and save or render errors are visible. No false success.
- Manual excerpt selection stays character-boundary exact.
- Linux has no Xcode. Do not claim an iOS test run. Do not invent a PNG.

## File structure

- Create `Socgent/Features/TweetDetail/QuoteCardModel.swift` — spec, fixtures, selection, fit, palette, direction.
- Create `Socgent/Features/TweetDetail/QuoteCardMeasurer.swift` — UIKit measurement.
- Create `Socgent/Features/TweetDetail/QuoteCardExport.swift` — render, deliver, dependency.
- Create `Socgent/Features/TweetDetail/Components/QuoteCardCanvas.swift` — clean card and scaled preview.
- Modify `Socgent/Features/TweetDetail/Reducer/TweetDetailReducer.swift` — fixture state and export gate.
- Modify `Socgent/Features/TweetDetail/Views/TweetDetailView.swift` — banner, picker, preview, actions.
- Modify `Socgent/Features/Social/Views/SocialView.swift` — stable detail store.
- Modify `Socgent/Core/ImageSaver.swift` — PNG save result.
- Modify `Socgent/CommonUI/TextView/SelectableTextView.swift` — readable text color.
- Modify `Socgent/Resources/Localizable.xcstrings` — new copy.
- Test `SocgentTests/QuoteCardLogicTests.swift`, `QuoteCardMeasurerTests.swift`, `TweetDetailReducerTests.swift`.

## Interfaces

```swift
enum QuoteCardSpec {
  static let pointWidth: CGFloat = 600
  static let pointHeight: CGFloat = 400
  static let exportScale: CGFloat = 3
  static let pixelWidth = 1800
  static let pixelHeight = 1200
  static func matchesExportPixels(width: Int, height: Int) -> Bool
}

enum ExcerptSelection {
  static func accepted(_ selection: String, in source: String) -> String?
}

enum QuoteCardFit: Equatable, Sendable {
  case fits
  case emptyExcerpt
  case excerptOverflow
  case attributionOverflow
}

@MainActor
enum QuoteCardMeasurer {
  static func evaluate(_ content: QuoteCardContent) -> QuoteCardFit
}
```

`QuoteCardExportClient.render` returns `Result<QuoteCardRenderedImage, QuoteCardExportFailure>`. `deliver` returns `cancelled`, `saved`, `shared`, or `failed`. The reducer ignores a result whose generation is not `renderGeneration`.

---

### Task 1: Model, measurer, and logic tests

**Files:** model, measurer, logic tests, measurer tests.

- [x] Write tests for 1800 by 1200, 3:2, exact emoji and Arabic excerpts, rejected selections, and measurer fit for the four fixtures plus a huge URL.
- [x] Implement spec, fixtures, selection, direction, and measurer.
- [ ] Command, when Xcode exists: `xcodebuild test -scheme Socgent -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:SocgentTests`
- [x] This Linux workspace: do not run that command. Record NOT RUN.

### Task 2: Reducer export gate

**Files:** `TweetDetailReducer.swift`, `TweetDetailReducerTests.swift`, export client stubs.

- [x] Test appear, long-fixture overflow, disabled export, duplicate taps, photos denial, share cancel, share failure, wrong pixel size, and stale generation.
- [x] Implement the reducer against `quoteCardMeasuring` and `quoteCardExport` dependencies.
- [x] Do not call `xClient`.

### Task 3: Canvas, render, share, save

**Files:** canvas, renderer, sharer, `ImageSaver`, detail view, social sheet, strings, selectable text color.

- [x] `ImageRenderer` proposed size 600 by 400 and scale 3. Reject other pixel sizes before deliver.
- [x] Share sheet popover uses the presenting view's center.
- [x] Preview scales `QuoteCardCanvas`. Overflow shows the placeholder, not a clipped card.
- [x] Keep the detail store in `@State` so a parent refresh does not drop the excerpt.

### Task 4: Manual check on a Mac

- [ ] Not run in this Linux workspace.

1. `xcodegen generate`
2. Run the Socgent scheme on an iPhone simulator and an iPad simulator.
3. Open Share X. Confirm the banner says the data is not a live tweet.
4. Normal, emoji, and RTL fixtures show the full excerpt, name, @handle, and example.com URL. Share and Save are enabled.
5. The long fixture disables both buttons and asks for a shorter excerpt. Highlight a short phrase. Buttons enable. The card text equals the selection.
6. Save. Confirm Photos receives one 1800 by 1200 image and the UI does not say saved if permission is denied.
7. Share, then cancel. Confirm no error banner.
8. Switch fixture while a share sheet is open, dismiss the sheet, and confirm the old image was not treated as the new card.

## Self-review

- Spec items map to Tasks 1–3. Pixel check is in the renderer and the reducer.
- Fixture copy stays outside `QuoteCardCanvas`.
- No provider, API, or AI task.
