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
