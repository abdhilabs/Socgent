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
        deps.recentSocialDB = makeLiveRecentSocialDB(container: container)
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
  
  private func makeLiveRecentSocialDB(container: ModelContainer) -> RecentSocialDatabaseClient {
    RecentSocialDatabaseClient(
      fetchAll: {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<SocialRecord>(
          sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        return try context.fetch(descriptor).map(Social.init(record:))
      },
      upsert: { item in
        let context = ModelContext(container)
        
        let social = item.social
        let descriptor = FetchDescriptor<SocialRecord>(
          predicate: #Predicate { $0.social == social }
        )
        let existing = try context.fetch(descriptor).first
        
        if let record = existing {
          record.social = item.social
          record.type = item.type.rawValue
          record.updatedAt = item.updatedAt
        } else {
          context.insert(SocialRecord(
            social: item.social,
            type: item.type.rawValue,
            updatedAt: item.updatedAt
          ))
        }
        
        try context.save()
      },
      delete: { item in
        let context = ModelContext(container)
        let social = item.social
        let descriptor = FetchDescriptor<SocialRecord>(
          predicate: #Predicate { $0.social == social }
        )
        if let record = try context.fetch(descriptor).first {
          context.delete(record)
          try context.save()
        }
      }
    )
  }
}
