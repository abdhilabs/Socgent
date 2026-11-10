//
//  QuoteCardLogicTests.swift
//  SocgentTests
//

import Testing
@testable import Socgent

struct QuoteCardLogicTests {
  @Test func exportSizeIs1800By1200AtThreeToTwo() {
    #expect(QuoteCardSpec.pointWidth == 600)
    #expect(QuoteCardSpec.pointHeight == 400)
    #expect(QuoteCardSpec.exportScale == 3)
    #expect(QuoteCardSpec.pixelWidth == 1800)
    #expect(QuoteCardSpec.pixelHeight == 1200)
    #expect(Int(QuoteCardSpec.pointWidth * QuoteCardSpec.exportScale) == QuoteCardSpec.pixelWidth)
    #expect(Int(QuoteCardSpec.pointHeight * QuoteCardSpec.exportScale) == QuoteCardSpec.pixelHeight)
    #expect(QuoteCardSpec.pointWidth / QuoteCardSpec.pointHeight == 1.5)
    #expect(QuoteCardSpec.matchesExportPixels(width: 1800, height: 1200))
    #expect(!QuoteCardSpec.matchesExportPixels(width: 1200, height: 1800))
    #expect(!QuoteCardSpec.matchesExportPixels(width: 1800, height: 1199))
  }

  @Test func fixturesAreLabeledSamplesNotLivePosts() {
    for id in QuoteFixtureID.allCases {
      let fixture = QuoteFixture.fixture(for: id)
      #expect(fixture.handle == "@sample")
      #expect(fixture.sourceURL.hasPrefix("https://example.com/fixture/"))
      #expect(!fixture.sourceURL.contains("twitter.com"))
      #expect(!fixture.sourceURL.contains("x.com"))
      #expect(fixture.content.excerpt == fixture.sourceText)
      #expect(fixture.content.authorName == fixture.authorName)
      #expect(fixture.content.handle == fixture.handle)
      #expect(fixture.content.sourceURL == fixture.sourceURL)
    }
    #expect(QuoteFixture.fixture(for: .long).sourceText.count > 220)
    #expect(QuoteFixture.fixture(for: .normal).sourceText.count < 220)
    #expect(QuoteFixture.fixture(for: .emoji).sourceText.count < 220)
    #expect(QuoteFixture.fixture(for: .rtl).sourceText.count < 220)
  }

  @Test func excerptKeepsExactCharacterBoundaries() {
    let family = "👨‍👩‍👧‍👦"
    let emojiSource = QuoteFixture.fixture(for: .emoji).sourceText
    let accepted = ExcerptSelection.accepted(family, in: emojiSource)
    #expect(accepted == family)
    #expect(accepted?.unicodeScalars.elementsEqual(family.unicodeScalars) == true)

    let arabic = "مثال قصير"
    let rtlSource = QuoteFixture.fixture(for: .rtl).sourceText
    #expect(ExcerptSelection.accepted(arabic, in: rtlSource) == arabic)

    let combining = "cafe\u{0301}"
    let acceptedCombining = ExcerptSelection.accepted("café", in: combining)
    #expect(acceptedCombining?.unicodeScalars.elementsEqual(combining.unicodeScalars) == true)
    #expect(acceptedCombining?.unicodeScalars.elementsEqual("café".unicodeScalars) == false)
    let combiningPart = ExcerptSelection.accepted("e\u{0301}", in: combining)
    #expect(combiningPart?.unicodeScalars.elementsEqual("e\u{0301}".unicodeScalars) == true)
    #expect(ExcerptSelection.accepted("", in: emojiSource) == nil)
    #expect(ExcerptSelection.accepted("not-in-source", in: emojiSource) == nil)
  }

  @Test func directionFollowsTheFirstStrongLetter() {
    #expect(QuoteCardDirection.isRightToLeft(QuoteFixture.fixture(for: .rtl).sourceText))
    #expect(QuoteCardDirection.isRightToLeft(QuoteFixture.fixture(for: .rtl).authorName))
    #expect(!QuoteCardDirection.isRightToLeft(QuoteFixture.fixture(for: .normal).sourceText))
    #expect(!QuoteCardDirection.isRightToLeft(QuoteFixture.fixture(for: .emoji).sourceText))
    #expect(!QuoteCardDirection.isRightToLeft("🚀✨"))
  }
}
