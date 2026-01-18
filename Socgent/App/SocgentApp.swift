//
//  SocgentApp.swift
//  Socgent
//
//  Created by Abdhilabs on 09/01/26.
//

import ComposableArchitecture
import PulseUI
import SwiftData
import SwiftUI

@main
struct SocgentApp: App {
  let container: ModelContainer
  
  var store: StoreOf<SocialReducer> {
    Store(
      initialState: SocialReducer.State(),
      reducer: {
        SocialReducer()
      },
      withDependencies: { deps in
        deps.recentSocialDB = .live(container: container)
      })
  }
  
  init() {
    do {
      container = try ModelContainer(for: SocialRecord.self)
    } catch {
      fatalError("Failed to create ModelContainer: \(error)")
    }
  }
  
  var body: some Scene {
    WindowGroup {
      StyleProvider {
        SocialView(store: store)
      }
    }
  }
}

#if DEBUG
extension UIWindow {
  open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    super.motionEnded(motion, with: event)
    if motion == .motionShake {
      let currentVC = UIWindow.current?.currentViewController
      
      if let currentVC, String(describing: currentVC.classForCoder).contains("\(ConsoleView.self)") {
        currentVC.dismiss(animated: true)
        return
      }
      
      let pulseVC = UIHostingController(rootView: NavigationStack { ConsoleView() })
      window?.endEditing(true)
      currentVC?.show(pulseVC, sender: currentVC)
    }
  }
}
#endif
