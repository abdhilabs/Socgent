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
  var getTweetDetail: @Sendable (_ id: String) async -> Result<TweetDetail, SocgentError>
}

extension DependencyValues {
  var xClient: XClient {
    get { self[XClientKey.self] }
    set { self[XClientKey.self] = newValue }
  }
}

private enum XClientKey: DependencyKey {
  static let liveValue: XClient = .init(
    getTweetDetail: { id in
      return await NetworkService.shared
        .request(.xAPI(api: .getTweetDetail(id: id)), as: TweetDetail.self)
    }
  )
}
