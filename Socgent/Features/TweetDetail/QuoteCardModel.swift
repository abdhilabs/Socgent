//
//  QuoteCardModel.swift
//  Socgent
//

import SwiftUI

enum QuoteCardSpec {
  static let pointWidth: CGFloat = 600
  static let pointHeight: CGFloat = 400
  static let exportScale: CGFloat = 3
  static let pixelWidth = 1800
  static let pixelHeight = 1200
  static let padding: CGFloat = 28
  static let sectionSpacing: CGFloat = 16
  static let attributionSpacing: CGFloat = 4
  static let safety: CGFloat = 12
  static let excerptFontSize: CGFloat = 26
  static let nameFontSize: CGFloat = 18
  static let handleFontSize: CGFloat = 15
  static let urlFontSize: CGFloat = 13

  static var contentWidth: CGFloat { pointWidth - (padding * 2) }
  static var measureWidth: CGFloat { contentWidth - 4 }

  static func matchesExportPixels(width: Int, height: Int) -> Bool {
    width == pixelWidth && height == pixelHeight
  }
}

enum QuoteFixtureID: String, CaseIterable, Equatable, Hashable, Sendable, Identifiable {
  case normal
  case long
  case emoji
  case rtl

  var id: Self { self }

  var titleKey: String {
    switch self {
    case .normal: "quote.fixture.normal"
    case .long: "quote.fixture.long"
    case .emoji: "quote.fixture.emoji"
    case .rtl: "quote.fixture.rtl"
    }
  }
}

struct QuoteFixture: Equatable, Sendable {
  var id: QuoteFixtureID
  var sourceText: String
  var authorName: String
  var handle: String
  var sourceURL: String

  var content: QuoteCardContent {
    QuoteCardContent(
      excerpt: sourceText,
      authorName: authorName,
      handle: handle,
      sourceURL: sourceURL
    )
  }

  static func fixture(for id: QuoteFixtureID) -> QuoteFixture {
    switch id {
    case .normal:
      QuoteFixture(
        id: .normal,
        sourceText: "A short sample quote, written for this card.",
        authorName: "Sample Author",
        handle: "@sample",
        sourceURL: "https://example.com/fixture/normal"
      )
    case .long:
      QuoteFixture(
        id: .long,
        sourceText: String(
          repeating: "This sample sentence is intentionally long so the quote card must ask for a shorter excerpt. ",
          count: 12
        ),
        authorName: "Sample Author",
        handle: "@sample",
        sourceURL: "https://example.com/fixture/long"
      )
    case .emoji:
      QuoteFixture(
        id: .emoji,
        sourceText: "Sample only 🚀✨ — family 👨‍👩‍👧‍👦 and flag 🇮🇩 stay intact.",
        authorName: "Sample Author",
        handle: "@sample",
        sourceURL: "https://example.com/fixture/emoji"
      )
    case .rtl:
      QuoteFixture(
        id: .rtl,
        sourceText: "هذا مثال قصير للبطاقة، وليس تغريدة حقيقية.",
        authorName: "اسم تجريبي",
        handle: "@sample",
        sourceURL: "https://example.com/fixture/rtl"
      )
    }
  }
}

struct QuoteCardContent: Equatable, Sendable {
  var excerpt: String
  var authorName: String
  var handle: String
  var sourceURL: String
}

enum ExcerptSelection {
  static func accepted(_ selection: String, in source: String) -> String? {
    guard !selection.isEmpty, source.range(of: selection) != nil else { return nil }
    return selection
  }
}

enum QuoteCardDirection {
  static func isRightToLeft(_ text: String) -> Bool {
    for character in text {
      for scalar in character.unicodeScalars {
        if CharacterSet.whitespacesAndNewlines.contains(scalar) { continue }
        switch scalar.value {
        case 0x0590...0x08FF, 0xFB1D...0xFDFF, 0xFE70...0xFEFF:
          return true
        default:
          break
        }
      }
      if character.isLetter { return false }
    }
    return false
  }
}

enum QuoteCardFit: Equatable, Sendable {
  case fits
  case emptyExcerpt
  case excerptOverflow
  case attributionOverflow
}

enum QuoteCardBlock: Equatable, Sendable {
  case measuring
  case ready
  case emptyExcerpt
  case excerptOverflow
  case attributionOverflow

  init(_ fit: QuoteCardFit) {
    switch fit {
    case .fits: self = .ready
    case .emptyExcerpt: self = .emptyExcerpt
    case .excerptOverflow: self = .excerptOverflow
    case .attributionOverflow: self = .attributionOverflow
    }
  }
}

enum QuoteCardExportKind: Equatable, Sendable {
  case share
  case save
}

enum QuoteCardExportFailure: Equatable, Sendable {
  case renderFailed
  case unexpectedDimensions(width: Int, height: Int)
  case encodeFailed
  case photosDenied
  case photosFailed
  case shareFailed
  case paletteFailed
}

enum QuoteCardExportResolution: Equatable, Sendable {
  case cancelled
  case saved
  case shared
  case failed(QuoteCardExportFailure)
}

enum QuoteCardResult: Equatable, Sendable {
  case saved
  case renderFailed
  case unexpectedDimensions
  case encodeFailed
  case photosDenied
  case photosFailed
  case shareFailed
  case paletteFailed

  init(_ failure: QuoteCardExportFailure) {
    switch failure {
    case .renderFailed: self = .renderFailed
    case .unexpectedDimensions: self = .unexpectedDimensions
    case .encodeFailed: self = .encodeFailed
    case .photosDenied: self = .photosDenied
    case .photosFailed: self = .photosFailed
    case .shareFailed: self = .shareFailed
    case .paletteFailed: self = .paletteFailed
    }
  }

  var localizationKey: String {
    switch self {
    case .saved: "quote.result.saved"
    case .renderFailed: "quote.error.render"
    case .unexpectedDimensions: "quote.error.dimensions"
    case .encodeFailed: "quote.error.encode"
    case .photosDenied: "quote.error.photosDenied"
    case .photosFailed: "quote.error.photosFailed"
    case .shareFailed: "quote.error.share"
    case .paletteFailed: "quote.error.palette"
    }
  }

  var isError: Bool { self != .saved }
}

extension QuoteCardBlock {
  var localizationKey: String? {
    switch self {
    case .measuring, .ready: nil
    case .emptyExcerpt: "quote.block.empty"
    case .excerptOverflow: "quote.block.excerpt"
    case .attributionOverflow: "quote.block.attribution"
    }
  }
}

struct RGBA: Equatable, Sendable {
  var red: Double
  var green: Double
  var blue: Double
  var opacity: Double

  var color: Color {
    Color(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
  }

  @MainActor
  init?(color: Color) {
    let resolved = UIColor(color).resolvedColor(with: UITraitCollection.current)
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var opacity: CGFloat = 0
    if resolved.getRed(&red, green: &green, blue: &blue, alpha: &opacity) {
      self.red = Double(red)
      self.green = Double(green)
      self.blue = Double(blue)
      self.opacity = Double(opacity)
      return
    }
    guard let components = resolved.cgColor.components, components.count >= 3 else { return nil }
    self.red = Double(components[0])
    self.green = Double(components[1])
    self.blue = Double(components[2])
    self.opacity = components.count > 3 ? Double(components[3]) : 1
  }
}

struct QuoteCardPalette: Equatable, Sendable {
  var background: RGBA
  var textPrimary: RGBA
  var textSecondary: RGBA
  var border: RGBA

  @MainActor
  init?(style: AppStyle) {
    guard
      let background = RGBA(color: style.colors.background.primary),
      let textPrimary = RGBA(color: style.colors.text.primary),
      let textSecondary = RGBA(color: style.colors.text.secondary),
      let border = RGBA(color: style.colors.border.primary)
    else { return nil }
    self.background = background
    self.textPrimary = textPrimary
    self.textSecondary = textSecondary
    self.border = border
  }
}

struct QuoteCardRenderedImage: Equatable, Sendable {
  var pngData: Data
  var pixelWidth: Int
  var pixelHeight: Int

  static let testExport = QuoteCardRenderedImage(
    pngData: Data([0x89, 0x50, 0x4E, 0x47]),
    pixelWidth: QuoteCardSpec.pixelWidth,
    pixelHeight: QuoteCardSpec.pixelHeight
  )
}
