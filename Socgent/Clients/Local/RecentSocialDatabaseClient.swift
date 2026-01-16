//
//  RecentSocialDatabaseClient.swift
//  Data
//
//  Created by Abdhilabs on 11/01/26.
//

import Foundation
import SwiftData
import ComposableArchitecture

struct RecentSocialDatabaseClient: Sendable {
  var fetchAll: @Sendable () throws -> [Social]
  var upsert: @Sendable (_ social: Social) throws -> Void
  var delete: @Sendable (_ social: Social) throws -> Void
}

extension RecentSocialDatabaseClient {
  static func live(container: ModelContainer) -> Self {
    Self(
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

extension DependencyValues {
  var recentSocialDB: RecentSocialDatabaseClient {
    get { self[RecentSocialDatabaseClientKey.self] }
    set { self[RecentSocialDatabaseClientKey.self] = newValue }
  }
}

private enum RecentSocialDatabaseClientKey: DependencyKey {
  static let liveValue: RecentSocialDatabaseClient = .init(
    fetchAll: { [] },
    upsert: { _ in },
    delete: { _ in }
  )
}
