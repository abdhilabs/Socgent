//
//  ImageSaver.swift
//  Socgent
//
//  Created by Abdhilabs on 17/01/26.
//

import UIKit
import Photos

actor ImageSaver: NSObject {
  static func saveImage(for image: UIImage) async -> Bool {
    let status = await requestAddAuthorizationIfNeeded()
    guard status == .authorized || status == .limited else {
      Log.error("Photo Library add permission not granted (\(status.rawValue))")
      return false
    }
    
    guard let pngData = image.pngData() else {
      Log.error("Failed to convert image to PNG data")
      return false
    }
    
    do {
      try await PHPhotoLibrary.shared().performChanges {
        let request = PHAssetCreationRequest.forAsset()
        request.addResource(with: .photo, data: pngData, options: nil)
      }
      return true
    } catch {
      Log.error("Error while saving image! (\(error.localizedDescription))")
      return false
    }
  }
  
  private static func requestAddAuthorizationIfNeeded() async -> PHAuthorizationStatus {
    let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
    if status != .notDetermined {
      return status
    }
    
    return await withCheckedContinuation { continuation in
      PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
        continuation.resume(returning: newStatus)
      }
    }
  }
}
