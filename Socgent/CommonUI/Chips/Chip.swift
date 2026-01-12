//
//  Chip.swift
//  Socgent
//
//  Created by Abdhilabs on 10/01/26.
//

import SwiftUI

struct Chip: View {
  @Environment(\.appStyle) var appStyle
  
  private let style: Style
  private let action: (() -> Void)?
  
  init(style: Style, action: (() -> Void)? = nil) {
    self.style = style
    self.action = action
  }
  
  var body: some View {
    HStack(alignment: .center, spacing: 8) {
      switch style.variant {
      case .iconOnly(let icon):
        icon
      case .label(let text):
        Text(text)
      case .labelWithIcon(let text, let icon):
        icon
        
        Text(text)
      }
    }
    .font(.caption)
    .foregroundStyle(appStyle.colors.text.primary)
    .padding(.vertical, 8)
    .padding(.horizontal, 12)
    .frame(maxWidth: style.fitContent ? nil : .infinity)
    .roundedBorder(appStyle.colors.border.primary, cornerRadius: 12)
    .asButton(action: action)
  }
}

#Preview {
  Chip(
    style: Chip.Style(
      variant: .label(text: "Label"),
      fitContent: true
    ),
    action: {
      
    }
  )
}
