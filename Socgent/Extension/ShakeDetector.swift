//
//  ShakeDetector.swift
//  Socgent
//
//  Created by Abdhilabs on 17/02/26.
//

import PulseUI
import SwiftUI
import UIKit

private final class ShakeDetectorView: UIView {
  var onShake: (() -> Void)?
  
  override var canBecomeFirstResponder: Bool { true }
  
  override func didMoveToWindow() {
    super.didMoveToWindow()
    if window != nil {
      becomeFirstResponder()
    }
  }
  
  override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    guard motion == .motionShake else { return }
    onShake?()
  }
}

private struct ShakeDetectorRepresentable: UIViewRepresentable {
  let onShake: () -> Void
  
  func makeUIView(context: Context) -> ShakeDetectorView {
    let view = ShakeDetectorView()
    view.onShake = onShake
    return view
  }
  
  func updateUIView(_ uiView: ShakeDetectorView, context: Context) {
    uiView.onShake = onShake
  }
}

private struct PulseConsoleOnShakeModifier: ViewModifier {
  @State private var isPresented = false
  
  func body(content: Content) -> some View {
    content
      .background(ShakeDetectorRepresentable(onShake: { isPresented = true }))
      .sheet(isPresented: $isPresented) {
        NavigationView {
          ConsoleView()
        }
      }
  }
}

extension View {
  func pulseConsoleOnShake() -> some View {
    modifier(PulseConsoleOnShakeModifier())
  }
}
