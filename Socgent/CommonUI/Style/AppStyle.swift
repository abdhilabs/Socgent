//
//  AppStyle.swift
//  Socgent
//
//  Created by Abdhilabs on 11/01/26.
//

import SwiftUI

enum StyleMode: String, CaseIterable {
  case light
  case dark
  case system
}

struct AppStyle {
  let colors: Colors
  
  struct Colors {
    let content: ContentColors
    let text: TextColors
    let border: BorderColors
    let background: BackgroundColors
  }
}

extension AppStyle {
  static let light = AppStyle(
    colors: Colors(
      content: LightContentColors(),
      text: LightTextColors(),
      border: LightBorderColors(),
      background: LightBackgroundColors()
    )
  )
  
  static let dark = AppStyle(
    colors: Colors(
      content: DarkContentColors(),
      text: DarkTextColors(),
      border: DarkBorderColors(),
      background: DarkBackgroundColors()
    )
  )
}
