//
//  SocgentError.swift
//  Socgent
//
//  Created by Abdhilabs on 11/01/26.
//

import Moya

enum SocgentError: Error {
  case swiftDataError(Error)
  case decodingError(Error)
  case networkError(MoyaError)
}

extension SocgentError: Equatable {
  static func == (lhs: SocgentError, rhs: SocgentError) -> Bool {
    switch (lhs, rhs) {
    case (.swiftDataError(let lhsError), .swiftDataError(let rhsError)):
      return lhsError.localizedDescription == rhsError.localizedDescription
    case (.decodingError(let lhsError), .decodingError(let rhsError)):
      return lhsError.localizedDescription == rhsError.localizedDescription
    case (.networkError(let lhsMoyaError), .networkError(let rhsMoyaError)):
        return lhsMoyaError.localizedDescription == rhsMoyaError.localizedDescription
    default:
      return false
    }
  }
}
