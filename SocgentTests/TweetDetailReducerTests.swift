//
//  TweetDetailReducerTests.swift
//  SocgentTests
//

import ComposableArchitecture
import Testing
@testable import Socgent

@MainActor
struct TweetDetailReducerTests {
  private let palette = QuoteCardPalette(
    background: RGBA(red: 1, green: 1, blue: 1, opacity: 1),
    textPrimary: RGBA(red: 0, green: 0, blue: 0, opacity: 1),
    textSecondary: RGBA(red: 0.4, green: 0.4, blue: 0.4, opacity: 1),
    border: RGBA(red: 0.8, green: 0.8, blue: 0.8, opacity: 1)
  )

  @Test func measuringStateIsRetriedOnAppear() async {
    var initial = TweetDetailReducer.State()
    initial.excerpt = QuoteFixture.fixture(for: .normal).sourceText
    initial.renderGeneration = 1
    initial.block = .measuring
    let store = TestStore(initialState: initial) {
      TweetDetailReducer()
    }
    await store.send(.onAppear)
    await store.receive(.fitResolved(generation: 1, fit: .fits)) {
      $0.block = .ready
    }
    #expect(store.state.canExport)
  }

  @Test func cancelledRenderDoesNotDeliver() async {
    let pause = Pause()
    let didDeliver = Delivered()
    let store = store {
      $0.quoteCardExport.render = { _, _ in
        await pause.wait()
        return .success(.testExport)
      }
      $0.quoteCardExport.deliver = { _, _ in
        didDeliver.value = true
        return .saved
      }
    }
    await appear(store)
    await store.send(.exportRequested(.save, palette: palette)) {
      $0.isExporting = true
      $0.result = nil
    }
    let shorter = "sample quote"
    await store.send(.excerptSelected(shorter)) {
      $0.excerpt = shorter
      $0.renderGeneration = 2
      $0.isExporting = false
      $0.block = .measuring
      $0.result = nil
    }
    pause.resume()
    await store.receive(.fitResolved(generation: 2, fit: .fits)) {
      $0.block = .ready
    }
    #expect(didDeliver.value == false)
    #expect(store.state.result == nil)
  }

  @Test func appearUsesTheNormalFixture() async {
    let store = store()
    await appear(store)
    #expect(store.state.excerpt == QuoteFixture.fixture(for: .normal).sourceText)
    #expect(store.state.canExport)
    await store.send(.onAppear)
  }

  @Test func longFixtureDisablesExportUntilTheExcerptIsShorter() async {
    let store = store()
    await appear(store)
    let longText = QuoteFixture.fixture(for: .long).sourceText
    await store.send(.fixtureSelected(.long)) {
      $0.fixtureID = .long
      $0.excerpt = longText
      $0.renderGeneration = 2
      $0.block = .measuring
      $0.isExporting = false
      $0.result = nil
    }
    await store.receive(.fitResolved(generation: 2, fit: .excerptOverflow)) {
      $0.block = .excerptOverflow
    }
    #expect(!store.state.canExport)
    await store.send(.exportRequested(.save, palette: palette))

    let shorter = "shorter excerpt"
    #expect(longText.contains(shorter))
    await store.send(.excerptSelected(shorter)) {
      $0.excerpt = shorter
      $0.renderGeneration = 3
      $0.block = .measuring
      $0.isExporting = false
      $0.result = nil
    }
    await store.receive(.fitResolved(generation: 3, fit: .fits)) {
      $0.block = .ready
    }
    #expect(store.state.excerpt == shorter)
    #expect(store.state.canExport)
  }

  @Test func selectionOutsideTheSourceIsIgnored() async {
    let store = store()
    await appear(store)
    await store.send(.excerptSelected("not-in-source"))
    await store.send(.excerptSelected(""))
    await store.send(.excerptSelected(store.state.excerpt))
    #expect(store.state.excerpt == QuoteFixture.fixture(for: .normal).sourceText)
  }

  @Test func emojiAndArabicSelectionsStayExact() async {
    let store = store()
    await appear(store)
    let emoji = QuoteFixture.fixture(for: .emoji)
    await store.send(.fixtureSelected(.emoji)) {
      $0.fixtureID = .emoji
      $0.excerpt = emoji.sourceText
      $0.renderGeneration = 2
      $0.block = .measuring
      $0.isExporting = false
      $0.result = nil
    }
    await store.receive(.fitResolved(generation: 2, fit: .fits)) {
      $0.block = .ready
    }
    let family = "👨‍👩‍👧‍👦"
    await store.send(.excerptSelected(family)) {
      $0.excerpt = family
      $0.renderGeneration = 3
      $0.block = .measuring
      $0.isExporting = false
      $0.result = nil
    }
    await store.receive(.fitResolved(generation: 3, fit: .fits)) {
      $0.block = .ready
    }
    #expect(store.state.excerpt.unicodeScalars.elementsEqual(family.unicodeScalars))
    #expect(store.state.content.authorName == emoji.authorName)
    #expect(store.state.content.handle == "@sample")
    #expect(store.state.content.sourceURL == emoji.sourceURL)

    let rtl = QuoteFixture.fixture(for: .rtl)
    await store.send(.fixtureSelected(.rtl)) {
      $0.fixtureID = .rtl
      $0.excerpt = rtl.sourceText
      $0.renderGeneration = 4
      $0.block = .measuring
      $0.isExporting = false
      $0.result = nil
    }
    await store.receive(.fitResolved(generation: 4, fit: .fits)) {
      $0.block = .ready
    }
    let arabic = "مثال قصير"
    await store.send(.excerptSelected(arabic)) {
      $0.excerpt = arabic
      $0.renderGeneration = 5
      $0.block = .measuring
      $0.isExporting = false
      $0.result = nil
    }
    await store.receive(.fitResolved(generation: 5, fit: .fits)) {
      $0.block = .ready
    }
    #expect(store.state.excerpt == arabic)
  }

  @Test func saveSuccessIsVisible() async {
    let store = store { $0.quoteCardExport.deliver = { _, _ in .saved } }
    await appear(store)
    await store.send(.exportRequested(.save, palette: palette)) {
      $0.isExporting = true
      $0.result = nil
    }
    await store.receive(.exportRendered(generation: 1, kind: .save, result: .success(.testExport)))
    await store.receive(.exportResolved(generation: 1, .saved)) {
      $0.isExporting = false
      $0.result = .saved
    }
  }

  @Test func duplicateExportIsIgnored() async {
    let store = store { $0.quoteCardExport.deliver = { _, _ in .saved } }
    await appear(store)
    await store.send(.exportRequested(.save, palette: palette)) {
      $0.isExporting = true
      $0.result = nil
    }
    await store.send(.exportRequested(.share, palette: palette))
    await store.receive(.exportRendered(generation: 1, kind: .save, result: .success(.testExport)))
    await store.receive(.exportResolved(generation: 1, .saved)) {
      $0.isExporting = false
      $0.result = .saved
    }
  }

  @Test func photosDenialIsNotSaved() async {
    let store = store { $0.quoteCardExport.deliver = { _, _ in .failed(.photosDenied) } }
    await appear(store)
    await store.send(.exportRequested(.save, palette: palette)) {
      $0.isExporting = true
      $0.result = nil
    }
    await store.receive(.exportRendered(generation: 1, kind: .save, result: .success(.testExport)))
    await store.receive(.exportResolved(generation: 1, .failed(.photosDenied))) {
      $0.isExporting = false
      $0.result = .photosDenied
    }
    #expect(store.state.result != .saved)
  }

  @Test func shareCancelIsNotAnError() async {
    let store = store()
    await appear(store)
    await store.send(.exportRequested(.share, palette: palette)) {
      $0.isExporting = true
      $0.result = nil
    }
    await store.receive(.exportRendered(generation: 1, kind: .share, result: .success(.testExport)))
    await store.receive(.exportResolved(generation: 1, .cancelled)) {
      $0.isExporting = false
    }
    #expect(store.state.result == nil)
  }

  @Test func shareFailureIsVisible() async {
    let store = store { $0.quoteCardExport.deliver = { _, _ in .failed(.shareFailed) } }
    await appear(store)
    await store.send(.exportRequested(.share, palette: palette)) {
      $0.isExporting = true
      $0.result = nil
    }
    await store.receive(.exportRendered(generation: 1, kind: .share, result: .success(.testExport)))
    await store.receive(.exportResolved(generation: 1, .failed(.shareFailed))) {
      $0.isExporting = false
      $0.result = .shareFailed
    }
  }

  @Test func wrongPixelSizeDoesNotDeliver() async {
    let store = store {
      $0.quoteCardExport.render = { _, _ in
        .success(QuoteCardRenderedImage(pngData: Data([1]), pixelWidth: 10, pixelHeight: 10))
      }
      $0.quoteCardExport.deliver = { _, _ in .saved }
    }
    await appear(store)
    await store.send(.exportRequested(.save, palette: palette)) {
      $0.isExporting = true
      $0.result = nil
    }
    let bad = QuoteCardRenderedImage(pngData: Data([1]), pixelWidth: 10, pixelHeight: 10)
    await store.receive(.exportRendered(generation: 1, kind: .save, result: .success(bad))) {
      $0.isExporting = false
      $0.result = .unexpectedDimensions(width: 10, height: 10)
    }
  }

  @Test func renderFailureIsVisible() async {
    let store = store { $0.quoteCardExport.render = { _, _ in .failure(.renderFailed) } }
    await appear(store)
    await store.send(.exportRequested(.save, palette: palette)) {
      $0.isExporting = true
      $0.result = nil
    }
    await store.receive(.exportRendered(generation: 1, kind: .save, result: .failure(.renderFailed))) {
      $0.isExporting = false
      $0.result = .renderFailed
    }
  }

  @Test func staleRenderIsDiscardedWhenTheExcerptChanges() async {
    let store = store { $0.quoteCardExport.deliver = { _, _ in .saved } }
    await appear(store)
    await store.send(.exportRequested(.save, palette: palette)) {
      $0.isExporting = true
      $0.result = nil
    }
    let shorter = "sample quote"
    await store.send(.excerptSelected(shorter)) {
      $0.excerpt = shorter
      $0.renderGeneration = 2
      $0.isExporting = false
      $0.block = .measuring
      $0.result = nil
    }
    await store.receive(.exportRendered(generation: 1, kind: .save, result: .success(.testExport)))
    await store.receive(.fitResolved(generation: 2, fit: .fits)) {
      $0.block = .ready
    }
    #expect(store.state.result == nil)
    #expect(store.state.excerpt == shorter)
    #expect(!store.state.isExporting)
  }

  private func store(
    _ update: (inout DependencyValues) -> Void = { _ in }
  ) -> TestStore<TweetDetailReducer.State, TweetDetailReducer.Action> {
    TestStore(
      initialState: TweetDetailReducer.State(),
      reducer: { TweetDetailReducer() },
      withDependencies: update
    )
  }

  private final class Pause: @unchecked Sendable {
    private var continuation: CheckedContinuation<Void, Never>?

    func wait() async {
      await withCheckedContinuation { continuation = $0 }
    }

    func resume() {
      continuation?.resume()
      continuation = nil
    }
  }

  private final class Delivered: @unchecked Sendable {
    var value = false
  }

  private func appear(
    _ store: TestStore<TweetDetailReducer.State, TweetDetailReducer.Action>
  ) async {
    let text = QuoteFixture.fixture(for: .normal).sourceText
    await store.send(.onAppear) {
      $0.excerpt = text
      $0.renderGeneration = 1
      $0.block = .measuring
      $0.isExporting = false
      $0.result = nil
    }
    await store.receive(.fitResolved(generation: 1, fit: .fits)) {
      $0.block = .ready
    }
  }
}
