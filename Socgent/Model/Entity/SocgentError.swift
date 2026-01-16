//
//  SocgentError.swift
//  Socgent
//
//  Created by Abdhilabs on 11/01/26.
//

import Foundation

enum SocgentError: Error {
  case swiftDataError(Error)
}

extension SocgentError: Equatable {
  static func == (lhs: SocgentError, rhs: SocgentError) -> Bool {
    switch (lhs, rhs) {
    case (.swiftDataError(let lhsError), .swiftDataError(let rhsError)):
      return lhsError.localizedDescription == rhsError.localizedDescription
    }
  }
}
