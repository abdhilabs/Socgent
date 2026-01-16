//
//  NetworkService.swift
//  Socgent
//
//  Created by Abdhilabs on 16/01/26.
//

import Foundation
import Moya
import Pulse

actor NetworkService {
  static let shared = NetworkService()
  
  private init() {}
  
  func request<T: Decodable>(
    _ api: SocgentAPI,
    as type: T.Type,
    decoder: JSONDecoder = JSONDecoder()
  ) async -> Result<T, SocgentError> {
    do {
      let result = try await requestData(api)
      let response = try decoder.decode(T.self, from: result)
      return .success(response)
    } catch {
      if let error = error as? MoyaError {
        return .failure(.networkError(error))
      } else {
        return .failure(.decodingError(error))
      }
    }
  }
  
  func requestData(_ api: SocgentAPI) async throws -> Data {
    try await withCheckedThrowingContinuation { continuation in
      let session = Session(eventMonitors: [SocgentNetworkLogger()])
      let provider = MoyaProvider<SocgentAPI>(session: session)
      provider.request(api) { result in
        switch result {
        case .success(let response):
          switch response.statusCode {
          case 200...299:
            continuation.resume(returning: response.data)
          default:
            continuation.resume(throwing: MoyaError.statusCode(response))
          }
        case .failure(let error):
          continuation.resume(throwing: error)
        }
      }
    }
  }
}
