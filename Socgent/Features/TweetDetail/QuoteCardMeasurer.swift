//
//  QuoteCardMeasurer.swift
//  Socgent
//

import ComposableArchitecture
import UIKit

@MainActor
enum QuoteCardMeasurer {
  static func evaluate(_ content: QuoteCardContent) -> QuoteCardFit {
    if content.excerpt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      return .emptyExcerpt
    }

    let width = QuoteCardSpec.measureWidth
    let cardDirection = writingDirection(for: content.excerpt)
    let excerptBox = measuredBox(
      content.excerpt,
      size: QuoteCardSpec.excerptFontSize,
      weight: .semibold,
      width: width,
      direction: cardDirection
    )
    let nameBox = measuredBox(
      content.authorName,
      size: QuoteCardSpec.nameFontSize,
      weight: .semibold,
      width: width,
      direction: cardDirection
    )
    let handleBox = measuredBox(
      content.handle,
      size: QuoteCardSpec.handleFontSize,
      weight: .regular,
      width: width,
      direction: cardDirection
    )
    let urlBox = measuredBox(
      content.sourceURL,
      size: QuoteCardSpec.urlFontSize,
      weight: .regular,
      width: width,
      direction: .leftToRight
    )
    if nameBox.widestToken > width || handleBox.widestToken > width || urlBox.widestToken > width {
      return .attributionOverflow
    }
    if excerptBox.widestToken > width {
      return .excerptOverflow
    }
    let attribution = nameBox.height + handleBox.height + urlBox.height + (QuoteCardSpec.attributionSpacing * 2)
    let chrome = (QuoteCardSpec.padding * 2) + QuoteCardSpec.sectionSpacing
    let oneLine = measuredBox(
      "Ag",
      size: QuoteCardSpec.excerptFontSize,
      weight: .semibold,
      width: width,
      direction: .leftToRight
    ).height
    if chrome + attribution + oneLine > QuoteCardSpec.pointHeight {
      return .attributionOverflow
    }
    let available = QuoteCardSpec.pointHeight - chrome - attribution - QuoteCardSpec.safety
    if excerptBox.height > available {
      return .excerptOverflow
    }
    return .fits
  }

  private static func writingDirection(for text: String) -> NSWritingDirection {
    QuoteCardDirection.isRightToLeft(text) ? .rightToLeft : .leftToRight
  }

  private static func measuredBox(
    _ text: String,
    size: CGFloat,
    weight: UIFont.Weight,
    width: CGFloat,
    direction: NSWritingDirection
  ) -> (height: CGFloat, widestToken: CGFloat) {
    let paragraph = NSMutableParagraphStyle()
    paragraph.lineBreakMode = .byWordWrapping
    paragraph.baseWritingDirection = direction
    let attributes: [NSAttributedString.Key: Any] = [
      .font: UIFont.systemFont(ofSize: size, weight: weight),
      .paragraphStyle: paragraph
    ]
    let rect = (text as NSString).boundingRect(
      with: CGSize(width: width, height: .greatestFiniteMagnitude),
      options: [.usesLineFragmentOrigin, .usesFontLeading],
      attributes: attributes,
      context: nil
    )
    var widestToken: CGFloat = 0
    let tokens = text.split { $0.isWhitespace || $0.isNewline }
    let pieces = tokens.isEmpty ? [Substring(text)] : tokens
    for token in pieces {
      let tokenRect = (String(token) as NSString).boundingRect(
        with: CGSize(width: .greatestFiniteMagnitude, height: size * 2),
        options: [.usesLineFragmentOrigin, .usesFontLeading],
        attributes: attributes,
        context: nil
      )
      widestToken = max(widestToken, ceil(tokenRect.width))
    }
    return (ceil(rect.height), widestToken)
  }
}

struct QuoteCardMeasuringClient: Sendable {
  var fit: @Sendable (QuoteCardContent) async -> QuoteCardFit
}

extension QuoteCardMeasuringClient: DependencyKey {
  static let liveValue = Self { content in
    await MainActor.run {
      QuoteCardMeasurer.evaluate(content)
    }
  }

  static let testValue = Self { content in
    let excerpt = content.excerpt.trimmingCharacters(in: .whitespacesAndNewlines)
    if excerpt.isEmpty { return .emptyExcerpt }
    if content.sourceURL.count > 500 { return .attributionOverflow }
    if excerpt.count > 220 { return .excerptOverflow }
    return .fits
  }
}

extension DependencyValues {
  var quoteCardMeasuring: QuoteCardMeasuringClient {
    get { self[QuoteCardMeasuringClient.self] }
    set { self[QuoteCardMeasuringClient.self] = newValue }
  }
}
