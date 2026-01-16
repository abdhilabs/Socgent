//
//  EnvConfig.swift
//  Socgent
//
//  Created by Abdhilabs on 16/01/26.
//

import Foundation

final class EnvConfig {
  enum ConfigKey: String {
    case token = "X_BEARER_TOKEN"
  }
  
  static func value(for key: ConfigKey) -> String {
    let environmentVariables: [String: String]? = {
      guard let variables = Bundle.main.object(forInfoDictionaryKey: "ConfigVariables") as? [String: String] else {
        print("Warning: 'ConfigVariables' key is missing or invalid in Info.plist.")
        return nil
      }
      return variables
    }()
    
    guard let unwrappedValue = environmentVariables?[key.rawValue] else {
      print("Warning: No value found for key '\(key.rawValue)' in ConfigVariables. Returning empty string.")
      return ""
    }
    
    return unwrappedValue
  }
}
