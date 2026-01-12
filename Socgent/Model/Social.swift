//
//  Social.swift
//  Domain
//
//  Created by Abdhilabs on 11/01/26.
//

import Foundation

enum SocialType: String, Equatable, CaseIterable {
  case shareX, whatsapp
  
  var label: String {
    switch self {
    case .shareX:
      "Share X"
    case .whatsapp:
      "Whatsapp"
    }
  }
}

struct Social: Equatable, Identifiable {
  let id: UUID
  var social: String
  var type: SocialType
  var updatedAt: Date
  
  init(id: UUID = UUID(), social: String, type: SocialType, updatedAt: Date) {
    self.id = id
    self.social = social
    self.type = type
    self.updatedAt = updatedAt
  }
}

extension Social {
  init(record: SocialRecord) {
    self.id = UUID()
    self.social = record.social
    self.type = SocialType(rawValue: record.type) ?? .shareX
    self.updatedAt = record.updatedAt
  }
}
