//
//  TweetDetailView.swift
//  Socgent
//

import ComposableArchitecture
import SwiftUI
import UIKit

struct TweetDetailView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.appStyle) private var style

  let store: StoreOf<TweetDetailReducer>

  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ScrollView {
        VStack(alignment: .leading, spacing: 12) {
          Text("quote.fixture.banner".localized)
            .font(.caption)
            .foregroundStyle(style.colors.text.secondary)

          Picker("quote.fixture.picker".localized, selection: viewStore.binding(
            get: \.fixtureID,
            send: { .fixtureSelected($0) }
          )) {
            ForEach(QuoteFixtureID.allCases) { id in
              Text(id.titleKey.localized).tag(id)
            }
          }
          .pickerStyle(.menu)

          if let palette = QuoteCardPalette(style: style) {
            QuoteCardPreview(content: viewStore.content, block: viewStore.block, palette: palette)
          } else {
            Text("quote.error.palette".localized)
              .font(.caption)
              .foregroundStyle(style.colors.content.danger)
          }

          if let notice = notice(for: viewStore.state) {
            Text(notice.text)
              .font(.caption)
              .foregroundStyle(notice.isError ? style.colors.content.danger : style.colors.text.secondary)
              .fixedSize(horizontal: false, vertical: true)
          }

          Text("quote.source.label".localized)
            .foregroundColor(style.colors.text.secondary)
            .font(.subheadline)

          SelectableTextView(
            text: viewStore.fixture.sourceText,
            textColor: UIColor(style.colors.text.primary),
            customActionTitle: "Highlight Tweet",
            onCustomAction: { viewStore.send(.excerptSelected($0)) }
          )
          .frame(minHeight: 160)
        }
        .padding(.horizontal, 16)
      }
      .background(style.colors.background.primary)
      .navigationTitle("quote.screen.title".localized)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button("Close") { dismiss() }
        }
        ToolbarItemGroup(placement: .topBarTrailing) {
          Button("quote.action.share".localized) {
            requestExport(.share, viewStore: viewStore)
          }
          .disabled(!viewStore.canExport)
          Button("quote.action.save".localized) {
            requestExport(.save, viewStore: viewStore)
          }
          .disabled(!viewStore.canExport)
        }
      }
      .task {
        await viewStore.send(.onAppear).finish()
      }
    }
  }

  private func requestExport(
    _ kind: QuoteCardExportKind,
    viewStore: ViewStore<TweetDetailReducer.State, TweetDetailReducer.Action>
  ) {
    guard let palette = QuoteCardPalette(style: style) else {
      viewStore.send(.exportRejected(.paletteFailed))
      return
    }
    viewStore.send(.exportRequested(kind, palette: palette))
  }

  private func notice(for state: TweetDetailReducer.State) -> (text: String, isError: Bool)? {
    if let key = state.block.localizationKey {
      return (key.localized, true)
    }
    guard let result = state.result else { return nil }
    if case .unexpectedDimensions(let width, let height) = result {
      return ("\(result.localizationKey.localized) (\(width)×\(height))", true)
    }
    return (result.localizationKey.localized, result.isError)
  }
}

#Preview {
  StyleProvider {
    NavigationStack {
      TweetDetailView(store: Store(initialState: TweetDetailReducer.State()) {
        TweetDetailReducer()
      })
    }
  }
}
