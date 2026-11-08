//
//  TweetDetailReducer.swift
//  Socgent
//

import ComposableArchitecture

@Reducer
struct TweetDetailReducer {
  @Dependency(\.quoteCardMeasuring) var measuring
  @Dependency(\.quoteCardExport) var exporting

  @ObservableState
  struct State: Equatable {
    var fixtureID: QuoteFixtureID = .normal
    var excerpt = ""
    var block: QuoteCardBlock = .measuring
    var isExporting = false
    var renderGeneration = 0
    var result: QuoteCardResult?

    var fixture: QuoteFixture { .fixture(for: fixtureID) }

    var content: QuoteCardContent {
      QuoteCardContent(
        excerpt: excerpt,
        authorName: fixture.authorName,
        handle: fixture.handle,
        sourceURL: fixture.sourceURL
      )
    }

    var canExport: Bool { block == .ready && !isExporting }
  }

  enum Action: Equatable {
    case onAppear
    case fixtureSelected(QuoteFixtureID)
    case excerptSelected(String)
    case fitResolved(generation: Int, fit: QuoteCardFit)
    case exportRequested(QuoteCardExportKind, palette: QuoteCardPalette)
    case exportRejected(QuoteCardExportFailure)
    case exportRendered(
      generation: Int,
      kind: QuoteCardExportKind,
      result: Result<QuoteCardRenderedImage, QuoteCardExportFailure>
    )
    case exportResolved(generation: Int, QuoteCardExportResolution)
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        guard state.renderGeneration == 0 else { return .none }
        return replaceExcerpt(state.fixture.sourceText, state: &state)

      case .fixtureSelected(let id):
        guard id != state.fixtureID else { return .none }
        state.fixtureID = id
        return replaceExcerpt(state.fixture.sourceText, state: &state)

      case .excerptSelected(let selection):
        guard let excerpt = ExcerptSelection.accepted(selection, in: state.fixture.sourceText) else {
          return .none
        }
        guard excerpt != state.excerpt else { return .none }
        return replaceExcerpt(excerpt, state: &state)

      case .fitResolved(let generation, let fit):
        guard generation == state.renderGeneration else { return .none }
        state.block = QuoteCardBlock(fit)
        return .none

      case .exportRequested(let kind, let palette):
        guard state.canExport else { return .none }
        state.isExporting = true
        state.result = nil
        let generation = state.renderGeneration
        let content = state.content
        return .run { send in
          let rendered = await exporting.render(content, palette)
          await send(.exportRendered(generation: generation, kind: kind, result: rendered))
        }

      case .exportRejected(let failure):
        state.result = QuoteCardResult(failure)
        return .none

      case .exportRendered(let generation, let kind, let result):
        guard generation == state.renderGeneration, state.isExporting else { return .none }
        switch result {
        case .failure(let failure):
          state.isExporting = false
          state.result = QuoteCardResult(failure)
          return .none
        case .success(let image):
          guard QuoteCardSpec.matchesExportPixels(width: image.pixelWidth, height: image.pixelHeight) else {
            state.isExporting = false
            state.result = .unexpectedDimensions
            return .none
          }
          return .run { send in
            let resolution = await exporting.deliver(image, kind)
            await send(.exportResolved(generation: generation, resolution))
          }
        }

      case .exportResolved(let generation, let resolution):
        guard generation == state.renderGeneration else { return .none }
        state.isExporting = false
        switch resolution {
        case .cancelled, .shared:
          break
        case .saved:
          state.result = .saved
        case .failed(let failure):
          state.result = QuoteCardResult(failure)
        }
        return .none
      }
    }
  }

  private func replaceExcerpt(_ excerpt: String, state: inout State) -> Effect<Action> {
    state.excerpt = excerpt
    state.renderGeneration += 1
    state.isExporting = false
    state.result = nil
    state.block = .measuring
    let generation = state.renderGeneration
    let content = state.content
    return .run { send in
      let fit = await measuring.fit(content)
      await send(.fitResolved(generation: generation, fit: fit))
    }
  }
}
