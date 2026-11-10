//
//  QuoteCardCanvas.swift
//  Socgent
//

import SwiftUI

struct QuoteCardCanvas: View {
  let content: QuoteCardContent
  let palette: QuoteCardPalette

  private var isRightToLeft: Bool {
    QuoteCardDirection.isRightToLeft(content.excerpt)
  }

  var body: some View {
    VStack(alignment: .leading, spacing: QuoteCardSpec.sectionSpacing) {
      Text(content.excerpt)
        .font(.system(size: QuoteCardSpec.excerptFontSize, weight: .semibold))
        .foregroundStyle(palette.textPrimary.color)
        .multilineTextAlignment(isRightToLeft ? .trailing : .leading)
        .lineSpacing(0)
        .frame(
          maxWidth: .infinity,
          alignment: isRightToLeft ? .topTrailing : .topLeading
        )

      Spacer(minLength: 0)

      VStack(alignment: .leading, spacing: QuoteCardSpec.attributionSpacing) {
        Text(content.authorName)
          .font(.system(size: QuoteCardSpec.nameFontSize, weight: .semibold))
          .foregroundStyle(palette.textPrimary.color)
        Text(content.handle)
          .font(.system(size: QuoteCardSpec.handleFontSize))
          .foregroundStyle(palette.textSecondary.color)
        Text(content.sourceURL)
          .font(.system(size: QuoteCardSpec.urlFontSize))
          .foregroundStyle(palette.textSecondary.color)
          .environment(\.layoutDirection, .leftToRight)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
    .padding(QuoteCardSpec.padding)
    .frame(width: QuoteCardSpec.pointWidth, height: QuoteCardSpec.pointHeight, alignment: .topLeading)
    .background(palette.background.color)
    .overlay {
      Rectangle().stroke(palette.border.color, lineWidth: 1)
    }
    .environment(\.layoutDirection, isRightToLeft ? .rightToLeft : .leftToRight)
  }
}

struct QuoteCardPreview: View {
  let content: QuoteCardContent
  let block: QuoteCardBlock
  let palette: QuoteCardPalette

  var body: some View {
    Color.clear
      .aspectRatio(QuoteCardSpec.pointWidth / QuoteCardSpec.pointHeight, contentMode: .fit)
      .overlay(alignment: .topLeading) {
        GeometryReader { geo in
          let scale = geo.size.width / QuoteCardSpec.pointWidth
          card
            .scaleEffect(scale, anchor: .topLeading)
            .frame(
              width: QuoteCardSpec.pointWidth * scale,
              height: QuoteCardSpec.pointHeight * scale,
              alignment: .topLeading
            )
        }
      }
      .clipped()
      .contentShape(Rectangle())
      .accessibilityElement(children: .contain)
  }

  @ViewBuilder
  private var card: some View {
    if block == .ready {
      QuoteCardCanvas(content: content, palette: palette)
    } else {
      QuoteCardPlaceholder(palette: palette)
    }
  }
}

struct QuoteCardPlaceholder: View {
  let palette: QuoteCardPalette

  var body: some View {
    palette.background.color
      .frame(width: QuoteCardSpec.pointWidth, height: QuoteCardSpec.pointHeight)
      .overlay {
        Rectangle().stroke(palette.border.color, lineWidth: 1)
      }
  }
}
