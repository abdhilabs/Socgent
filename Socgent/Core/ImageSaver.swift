//
//  ImageSaver.swift
//  Socgent
//

import Foundation
import Photos

enum PhotoLibrarySaveResult: Equatable, Sendable {
  case saved
  case denied
  case failed
}

actor ImageSaver: NSObject {
  nonisolated static func savePNG(_ data: Data) async -> PhotoLibrarySaveResult {
    let status = await requestAddAuthorizationIfNeeded()
    guard status == .authorized || status == .limited else { return .denied }

    do {
      try await PHPhotoLibrary.shared().performChanges {
        let request = PHAssetCreationRequest.forAsset()
        request.addResource(with: .photo, data: data, options: nil)
      }
      return .saved
    } catch {
      return .failed
    }
  }

  nonisolated private static func requestAddAuthorizationIfNeeded() async -> PHAuthorizationStatus {
    let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
    if status != .notDetermined { return status }

    return await withCheckedContinuation { continuation in
      PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
        continuation.resume(returning: newStatus)
      }
    }
  }
}
