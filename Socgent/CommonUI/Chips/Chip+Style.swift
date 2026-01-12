//
//  Chip+Style.swift
//  Socgent
//
//  Created by Abdhilabs on 10/01/26.
//

import Foundation

extension Chip {
  struct Style {
    let variant: Variant
    let fitContent: Bool
    
    init(variant: Variant, fitContent: Bool = true) {
      self.variant = variant
      self.fitContent = fitContent
    }
  }
  
  enum Variant {
    case label(text: String)
    case iconOnly(icon: Icon)
    case labelWithIcon(text: String, icon: Icon)
  }
}
