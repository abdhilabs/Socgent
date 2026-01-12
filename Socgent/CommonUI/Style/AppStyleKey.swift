//
//  AppStyleKey.swift
//  Socgent
//
//  Created by Abdhilabs on 12/01/26.
//

import SwiftUI

private struct AppStyleKey: EnvironmentKey {
  static let defaultValue: AppStyle = .light
}

extension EnvironmentValues {
  var appStyle: AppStyle {
    get { self[AppStyleKey.self] }
    set { self[AppStyleKey.self] = newValue }
  }
}
