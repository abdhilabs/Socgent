//
//  Icon.swift
//  Socgent
//
//  Created by Abdhilabs on 10/01/26.
//

import SwiftUI

struct Icon: View {
  let resourceName: String
  let color: Color?
  let size: Size
  
  private init(
    _ resourceName: String,
    color: Color? = nil,
    size: Size = .size16
  ) {
    self.resourceName = resourceName
    self.color = color
    self.size = size
  }
  
  var body: some View {
    Image(resourceName)
      .resizable()
      .if(color.isNotNil) { image in
        image.imageColor(color)
      }
      .frame(width: size.rawValue, height: size.rawValue)
  }
  
  enum Size: CGFloat {
    case size16 = 16
    case size24 = 24
  }
}

extension Icon {
  /// Initialize Icon System
  /// Tint color is changeable
  static func sys(_ resourceName: String, size: Size = .size16, color: Color? = nil) -> Icon {
    return Icon(resourceName, color: color, size: size)
  }
  
  static func product(_ name: Icon.Product, size: Size = .size16, color: Color? = nil) -> Icon {
    let resourceName = "ic_" + name.rawValue
    return Icon(resourceName, color: color, size: size)
  }
}
