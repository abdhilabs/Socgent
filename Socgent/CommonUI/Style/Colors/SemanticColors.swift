//
//  SemanticColors.swift
//  Socgent
//
//  Created by Abdhilabs on 11/01/26.
//

import SwiftUI

protocol ContentColors: Sendable {
  var primary: Color { get }
  var secondary: Color { get }
  var disabled: Color { get }
  var warning: Color { get }
  var danger: Color { get }
  var success: Color { get }
}

protocol TextColors: Sendable {
  var primary: Color { get }
  var secondary: Color { get }
  var tertiary: Color { get }
}

protocol BorderColors: Sendable {
  var primary: Color { get }
  var divider: Color { get }
}

protocol BackgroundColors: Sendable {
  var primary: Color { get }
  var surface: Color { get }
}
