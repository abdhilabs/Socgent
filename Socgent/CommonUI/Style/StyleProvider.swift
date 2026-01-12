//
//  StyleProvider.swift
//  Socgent
//
//  Created by Abdhilabs on 12/01/26.
//

import SwiftUI

final class StyleSettings: ObservableObject {
  @AppStorage("style.mode") var mode: StyleMode = .system
}

struct StyleProvider<Content: View>: View {
  @Environment(\.colorScheme) private var colorScheme
  
  @StateObject private var settings = StyleSettings()
  
  let content: Content
  
  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }
  
  private var resolvedStyle: AppStyle {
    switch settings.mode {
    case .system:
      return colorScheme == .dark ? .dark : .light
    case .light:
      return .light
    case .dark:
      return .dark
    }
  }
  
  var body: some View {
    content
      .environment(\.appStyle, resolvedStyle)
  }
}
