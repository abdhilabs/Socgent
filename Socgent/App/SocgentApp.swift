//
//  SocgentApp.swift
//  Socgent
//
//  Created by Abdhilabs on 09/01/26.
//

import ComposableArchitecture
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
