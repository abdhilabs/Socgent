//
//  QuoteCardExport.swift
//  Socgent
//

import ComposableArchitecture
import SwiftUI
import UIKit

@MainActor
enum QuoteCardRenderer {
  static func render(
    content: QuoteCardContent,
    palette: QuoteCardPalette
  ) -> Result<QuoteCardRenderedImage, QuoteCardExportFailure> {
    let canvas = QuoteCardCanvas(content: content, palette: palette)
      .frame(width: QuoteCardSpec.pointWidth, height: QuoteCardSpec.pointHeight)
    let renderer = ImageRenderer(content: canvas)
    renderer.proposedSize = ProposedViewSize(
      width: QuoteCardSpec.pointWidth,
      height: QuoteCardSpec.pointHeight
    )
    renderer.scale = QuoteCardSpec.exportScale
    renderer.isOpaque = true

    guard let image = renderer.uiImage else { return .failure(.renderFailed) }
    let width = Int((image.size.width * image.scale).rounded())
    let height = Int((image.size.height * image.scale).rounded())
    guard QuoteCardSpec.matchesExportPixels(width: width, height: height) else {
      return .failure(.unexpectedDimensions(width: width, height: height))
    }
    guard let pngData = image.pngData(), !pngData.isEmpty else { return .failure(.encodeFailed) }
    return .success(QuoteCardRenderedImage(pngData: pngData, pixelWidth: width, pixelHeight: height))
  }
}

enum QuoteCardExportCoordinator {
  static func deliver(
    _ image: QuoteCardRenderedImage,
    kind: QuoteCardExportKind
  ) async -> QuoteCardExportResolution {
    switch kind {
    case .save:
      switch await ImageSaver.savePNG(image.pngData) {
      case .saved: return .saved
      case .denied: return .failed(.photosDenied)
      case .failed: return .failed(.photosFailed)
      }
    case .share:
      return await QuoteCardSharer.present(pngData: image.pngData)
    }
  }
}

@MainActor
enum QuoteCardSharer {
  static func present(pngData: Data) async -> QuoteCardExportResolution {
    guard let image = UIImage(data: pngData) else { return .failed(.encodeFailed) }
    guard let presenter = UIWindow.current?.currentViewController else { return .failed(.shareFailed) }
    presenter.loadViewIfNeeded()
    guard let source = presenter.view else { return .failed(.shareFailed) }

    return await withCheckedContinuation { continuation in
      let once = ResumeOnce()
      let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
      controller.completionWithItemsHandler = { _, completed, _, error in
        once.run {
          if error != nil {
            continuation.resume(returning: .failed(.shareFailed))
          } else if completed {
            continuation.resume(returning: .shared)
          } else {
            continuation.resume(returning: .cancelled)
          }
        }
      }

      if let popover = controller.popoverPresentationController {
        popover.sourceView = source
        popover.sourceRect = CGRect(x: source.bounds.midX, y: source.bounds.midY, width: 1, height: 1)
        popover.permittedArrowDirections = []
      }
      if presenter.presentedViewController != nil {
        once.run { continuation.resume(returning: .failed(.shareFailed)) }
        return
      }
      presenter.present(controller, animated: true)
    }
  }
}

private final class ResumeOnce: @unchecked Sendable {
  private let lock = NSLock()
  private var done = false

  func run(_ body: () -> Void) {
    lock.lock()
    if done {
      lock.unlock()
      return
    }
    done = true
    lock.unlock()
    body()
  }
}

struct QuoteCardExportClient: Sendable {
  var render: @Sendable (QuoteCardContent, QuoteCardPalette) async -> Result<QuoteCardRenderedImage, QuoteCardExportFailure>
  var deliver: @Sendable (QuoteCardRenderedImage, QuoteCardExportKind) async -> QuoteCardExportResolution
}

extension QuoteCardExportClient: DependencyKey {
  static let liveValue = Self(
    render: { content, palette in
      await MainActor.run {
        QuoteCardRenderer.render(content: content, palette: palette)
      }
    },
    deliver: { image, kind in
      await QuoteCardExportCoordinator.deliver(image, kind: kind)
    }
  )

  static let testValue = Self(
    render: { _, _ in .success(.testExport) },
    deliver: { _, _ in .cancelled }
  )
}

extension DependencyValues {
  var quoteCardExport: QuoteCardExportClient {
    get { self[QuoteCardExportClient.self] }
    set { self[QuoteCardExportClient.self] = newValue }
  }
}
