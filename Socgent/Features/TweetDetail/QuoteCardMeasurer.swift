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
    let excerptHeight = measuredHeight(
      content.excerpt,
      size: QuoteCardSpec.excerptFontSize,
      weight: .semibold,
      width: width,
      direction: cardDirection
    )
    let nameHeight = measuredHeight(
      content.authorName,
      size: QuoteCardSpec.nameFontSize,
      weight: .semibold,
      width: width,
      direction: cardDirection
    )
    let handleHeight = measuredHeight(
      content.handle,
      size: QuoteCardSpec.handleFontSize,
      weight: .regular,
      width: width,
      direction: cardDirection
    )
    let urlHeight = measuredHeight(
      content.sourceURL,
      size: QuoteCardSpec.urlFontSize,
      weight: .regular,
      width: width,
      direction: .leftToRight
    )
    let attribution = nameHeight + handleHeight + urlHeight + (QuoteCardSpec.attributionSpacing * 2)
    let chrome = (QuoteCardSpec.padding * 2) + QuoteCardSpec.sectionSpacing
    let oneLine = measuredHeight(
      "Ag",
      size: QuoteCardSpec.excerptFontSize,
      weight: .semibold,
      width: width,
      direction: .leftToRight
    )
    if chrome + attribution + oneLine > QuoteCardSpec.pointHeight {
      return .attributionOverflow
    }
    let available = QuoteCardSpec.pointHeight - chrome - attribution - QuoteCardSpec.safety
    if excerptHeight > available {
      return .excerptOverflow
    }
    return .fits
  }

  private static func writingDirection(for text: String) -> NSWritingDirection {
    QuoteCardDirection.isRightToLeft(text) ? .rightToLeft : .leftToRight
  }

  private static func measuredHeight(
    _ text: String,
    size: CGFloat,
    weight: UIFont.Weight,
    width: CGFloat,
    direction: NSWritingDirection
  ) -> CGFloat {
    let paragraph = NSMutableParagraphStyle()
    paragraph.lineBreakMode = .byWordWrapping
    paragraph.baseWritingDirection = direction
    let rect = (text as NSString).boundingRect(
      with: CGSize(width: width, height: .greatestFiniteMagnitude),
      options: [.usesLineFragmentOrigin, .usesFontLeading],
      attributes: [
        .font: UIFont.systemFont(ofSize: size, weight: weight),
        .paragraphStyle: paragraph
      ],
      context: nil
    )
    return ceil(rect.height)
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
