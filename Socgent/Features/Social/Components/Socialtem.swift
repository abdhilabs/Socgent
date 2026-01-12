//
//  Socialtem.swift
//  Socgent
//
//  Created by Abdhilabs on 10/01/26.
//

import ComposableArchitecture
import SwiftUI

struct Socialtem: View {
  @Environment(\.appStyle) var style
  
  let item: Social
  
  var iconName: Icon.Product {
    switch item.type {
    case .shareX:
      return .twitter
    case .whatsapp:
      return .whatsapp
    }
  }
  
  var body: some View {
    HStack(spacing: 8) {
      Icon.product(iconName, color: style.colors.text.primary)
      
      Text(item.social)
        .font(.caption)
        .foregroundStyle(style.colors.text.primary)
      
      Spacer()
      
      Image(systemName: "chevron.right")
        .foregroundStyle(style.colors.text.primary)
    }
  }
}

#Preview {
  Socialtem(item: Social(social: "Social", type: .whatsapp, updatedAt: .now))
}
