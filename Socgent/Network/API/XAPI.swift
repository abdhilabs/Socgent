//
//  XAPI.swift
//  Socgent
//
//  Created by Abdhilabs on 16/01/26.
//

import Foundation
import Moya

enum XAPI {
  case getTweetDetail(id: String)
}

extension XAPI: TargetType {  
  var path: String {
    switch self {
    case .getTweetDetail(let id):
      // https://api.twitter.com/2/tweets/2011980103484653780?tweet.fields=created_at,author_id,text&user.fields=username,name
      return "/2/tweets/\(id)"
    }
  }
  
  var method: Moya.Method {
    .get
  }
  
  var task: Moya.Task {
    switch self {
    case .getTweetDetail:
      return .requestParameters(parameters: ["tweet.fields": "created_at,author_id,text", "user.fields": "username,name"], encoding: URLEncoding.queryString)
    }
  }
  
  var baseURL: URL { URL(string: "")!}
  var headers: [String: String]? { [:] }
}
