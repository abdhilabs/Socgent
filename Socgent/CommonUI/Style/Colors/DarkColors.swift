//
//  DarkColor.swift
//  Socgent
//
//  Created by Abdhilabs on 11/01/26.
//

import SwiftUI

struct DarkContentColors: ContentColors {
  var primary: Color { Color(hex: PrimitiveColors.primaryLight) }
  var secondary: Color { Color(hex: PrimitiveColors.secondarySlate) }
  var disabled: Color { Color.gray }
  var warning: Color { Color(hex: PrimitiveColors.warning) }
  var danger: Color { Color(hex: PrimitiveColors.error) }
  var success: Color { Color(hex: PrimitiveColors.success) }
}

struct DarkTextColors: TextColors {
  var primary: Color { Color(hex: PrimitiveColors.textPrimaryLight) }
  var secondary: Color { Color(hex: PrimitiveColors.textSecondaryLight) }
  var tertiary: Color { Color(hex: PrimitiveColors.textTertiaryLight) }
}

struct DarkBorderColors: BorderColors {
  var primary: Color { Color(hex: PrimitiveColors.borderLight) }
  var divider: Color { Color(hex: PrimitiveColors.dividerLight) }
}

struct DarkBackgroundColors: BackgroundColors {
  var primary: Color { Color(hex: PrimitiveColors.bgDark) }
  var surface: Color { Color(hex: PrimitiveColors.surfaceDark) }
}
