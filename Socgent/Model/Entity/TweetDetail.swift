//
//  TweetDetail.swift
//  Socgent
//
//  Created by Abdhilabs on 16/01/26.
//

import Foundation

struct TweetDetail: Codable {
  var data: Data?
  var includes: Includes?
  
  enum CodingKeys: String, CodingKey {
    case data
    case includes
  }
}

extension TweetDetail {
  struct Data: Codable {
    var id: String?
    var createdAt: String?
    var text: String?
    var authorId: String?
    
    enum CodingKeys: String, CodingKey {
      case id
      case createdAt = "created_at"
      case text
      case authorId = "author_id"
    }
  }
  
  struct Includes: Codable {
    var users: [Users]?
    
    enum CodingKeys: String, CodingKey {
      case users
    }
  }
  
  struct Users: Codable {
    var username: String?
    var name: String?
    var id: String?
    
    enum CodingKeys: String, CodingKey {
      case username
      case name
      case id
    }
  }
}

extension TweetDetail {
  func toTweetCard() -> TweetCardItem {
    let user = includes?.users?.first(where: { $0.id == data?.authorId })
    return TweetCardItem(
      username: "@" + (user?.username ?? ""),
      name: user?.name ?? "",
      text: data?.text ?? ""
    )
  }
}
