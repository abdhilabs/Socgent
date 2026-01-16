//
//  SocgentAPI.swift
//  Socgent
//
//  Created by Abdhilabs on 16/01/26.
//

import Foundation
import Moya

enum SocgentAPI {
  case xAPI(api: XAPI)
}

extension SocgentAPI: TargetType {
  var baseURL: URL {
    switch self {
    case .xAPI:
      return URL(string: "https://api.twitter.com")!
    }
  }
  
  var path: String {
    switch self {
    case .xAPI(let api):
      return api.path
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .xAPI(let api):
      return api.method
    }
  }
  
  var task: Moya.Task {
    switch self {
    case .xAPI(let api):
      return api.task
    }
  }
  
  var headers: [String: String]? {
    switch self {
    case .xAPI:
      return [
        "Authorization": "Bearer \(EnvConfig.value(for: .token))"
      ]
    }
  }
}
