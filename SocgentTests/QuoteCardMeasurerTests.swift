//
//  QuoteCardMeasurerTests.swift
//  SocgentTests
//

import Testing
@testable import Socgent

@MainActor
struct QuoteCardMeasurerTests {
  @Test func readableFixturesFit() {
    for id in [QuoteFixtureID.normal, .emoji, .rtl] {
      #expect(QuoteCardMeasurer.evaluate(QuoteFixture.fixture(for: id).content) == .fits)
    }
  }

  @Test func longFixtureAsksForAShorterExcerpt() {
    let fit = QuoteCardMeasurer.evaluate(QuoteFixture.fixture(for: .long).content)
    #expect(fit == .excerptOverflow)
  }

  @Test func blankExcerptDoesNotFit() {
    var content = QuoteFixture.fixture(for: .normal).content
    content.excerpt = " \n "
    #expect(QuoteCardMeasurer.evaluate(content) == .emptyExcerpt)
  }

  @Test func hugeLinkDoesNotFit() {
    var content = QuoteFixture.fixture(for: .normal).content
    content.excerpt = "Hi"
    content.sourceURL = String(repeating: "https://example.com/fixture/", count: 40)
    #expect(QuoteCardMeasurer.evaluate(content) == .attributionOverflow)
  }

  @Test func rendererProduces1800By1200() {
    let content = QuoteFixture.fixture(for: .normal).content
    switch QuoteCardRenderer.render(content: content, palette: testPalette) {
    case .success(let image):
      #expect(image.pixelWidth == 1800)
      #expect(image.pixelHeight == 1200)
      #expect(!image.pngData.isEmpty)
    case .failure(let failure):
      Issue.record("Expected a 1800x1200 render, got \(failure)")
    }
  }
}

private let testPalette = QuoteCardPalette(
  background: RGBA(red: 0.99, green: 0.99, blue: 0.97, opacity: 1),
  textPrimary: RGBA(red: 0.12, green: 0.13, blue: 0.11, opacity: 1),
  textSecondary: RGBA(red: 0.34, green: 0.37, blue: 0.33, opacity: 1),
  border: RGBA(red: 0.90, green: 0.91, blue: 0.88, opacity: 1)
)
