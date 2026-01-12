//
//  LightColors.swift
//  Socgent
//
//  Created by Abdhilabs on 11/01/26.
//

import SwiftUI

struct LightContentColors: ContentColors {
  var primary: Color { Color(hex: PrimitiveColors.primaryDark) }
  var secondary: Color { Color(hex: PrimitiveColors.secondarySlateDark) }
  var disabled: Color { Color.gray }
  var warning: Color { Color(hex: PrimitiveColors.warning) }
  var danger: Color { Color(hex: PrimitiveColors.error) }
  var success: Color { Color(hex: PrimitiveColors.success) }
}

struct LightTextColors: TextColors {
  var primary: Color { Color(hex: PrimitiveColors.textPrimaryDark) }
  var secondary: Color { Color(hex: PrimitiveColors.textSecondaryDark) }
  var tertiary: Color { Color(hex: PrimitiveColors.textTertiaryDark) }
}

struct LightBorderColors: BorderColors {
  var primary: Color { Color(hex: PrimitiveColors.borderDark) }
  var divider: Color { Color(hex: PrimitiveColors.dividerDark) }
}

struct LightBackgroundColors: BackgroundColors {
  var primary: Color { Color(hex: PrimitiveColors.bgLight) }
  var surface: Color { Color(hex: PrimitiveColors.surfaceLight) }
}
