//
//  SocialRecord.swift
//  Domain
//
//  Created by Abdhilabs on 11/01/26.
//

import Foundation
import SwiftData

@Model
class SocialRecord {
  @Attribute(.unique) var social: String
  var type: String
  var updatedAt: Date
  
  init(social: String, type: String, updatedAt: Date) {
    self.social = social
    self.type = type
    self.updatedAt = updatedAt
  }
}
