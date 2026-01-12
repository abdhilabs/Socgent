//
//  StylePreferenceClient.swift
//  Socgent
//
//  Created by Abdhilabs on 12/01/26.
//

import ComposableArchitecture
import Foundation

struct StylePreferenceClient: Sendable {
  var load: @Sendable () -> StyleMode
  var save: @Sendable (StyleMode) -> Void
}

extension StylePreferenceClient: DependencyKey {
  static let liveValue = Self(
    load: {
      let raw = UserDefaults.standard.string(forKey: "style.mode") ?? StyleMode.system.rawValue
      return StyleMode(rawValue: raw) ?? .system
    },
    save: { mode in
      UserDefaults.standard.set(mode.rawValue, forKey: "style.mode")
    }
  )
}

extension DependencyValues {
  var stylePreference: StylePreferenceClient {
    get { self[StylePreferenceClient.self] }
    set { self[StylePreferenceClient.self] = newValue }
  }
}
