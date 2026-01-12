//
//  Image.swift
//  Socgent
//
//  Created by Abdhilabs on 10/01/26.
//

import SwiftUI

public extension Image {
  func imageColor(_ color: Color?) -> some View {
    self
      .renderingMode(.template)
      .foregroundColor(color)
  }
}
