//
//  Log.swift
//  Socgent
//
//  Created by Abdhilabs on 16/01/26.
//

import Foundation
import Pulse

enum Log {
  static func info(_ items: Any..., separator: String = "", terminator: String = "\n") {
#if DEBUG
    let prefix = "🔵 [Socgent LOG] >> "
    let message = items.map { item -> String in
      if let optional = item as? CustomStringConvertible {
        return String(describing: optional)
      } else {
        return "\(item)"
      }
    }.joined(separator: separator)
    LoggerStore.shared.storeMessage(
      createdAt: Date(),
      label: "🔵",
      level: .debug,
      message: message,
      metadata: nil
    )
    print("\(prefix)\(message)", terminator: terminator)
#endif
  }
  
  static func error(_ items: Any..., separator: String = "", terminator: String = "\n") {
#if DEBUG
    let prefix = "🔴 [Socgent LOG] >> "
    let message = items.map { item -> String in
      if let optional = item as? CustomStringConvertible {
        return String(describing: optional)
      } else {
        return "\(item)"
      }
    }.joined(separator: separator)
    LoggerStore.shared.storeMessage(
      createdAt: Date(),
      label: "🔴",
      level: .error,
      message: message,
      metadata: nil
    )
    print("\(prefix)\(message)", terminator: terminator)
#endif
  }
}
