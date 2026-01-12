//
//  View.swift
//  Socgent
//
//  Created by Abdhilabs on 10/01/26.
//

import SwiftUI

public extension View {
  @ViewBuilder
  func `if`<Content: View>(_ condition: @autoclosure () -> Bool, transformTrue: (Self) -> Content, transformFalse: ((Self) -> Content)? = nil) -> some View {
    if condition() {
      transformTrue(self)
    } else {
      if let transformFalse {
        transformFalse(self)
      } else {
        self
      }
    }
  }
  
  @ViewBuilder
  func roundedBorder<S>(_ content: S, width: CGFloat = 1, cornerRadius: CGFloat) -> some View where S: ShapeStyle {
    let roundedRect = RoundedRectangle(cornerRadius: cornerRadius)
    clipShape(roundedRect)
      .overlay(roundedRect.strokeBorder(content, lineWidth: width))
  }
  
  @ViewBuilder
  func asButton(action: (() -> Void)? = nil) -> some View {
    if let action {
      AnyView(Button {
        action()
      } label: {
        self
      })
    } else {
      AnyView(self)
    }
  }
  
  @ViewBuilder
  func isHidden(_ isHidden: Bool, isEmptyView: Bool = true) -> some View {
    if isHidden {
      if !isEmptyView {
        self.hidden()
      }
    } else {
      self
    }
  }
}
