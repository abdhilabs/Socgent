//
//  XClient.swift
//  Socgent
//
//  Created by Abdhilabs on 16/01/26.
//

import Foundation
import SwiftData
import ComposableArchitecture

struct XClient: Sendable {
  var detailTweet: @Sendable (_ id: String) async throws -> TweetDetail
}

extension DependencyValues {
  var xClient: XClient {
    get { self[XClientKey.self] }
    set { self[XClientKey.self] = newValue }
  }
}

private enum XClientKey: DependencyKey {
  static let liveValue: XClient = .init(
    detailTweet: { id in
      return try await NetworkService.shared
        .request(.xAPI(api: .getTweetDetail(id: id)), as: TweetDetail.self)
    }
  )
}
