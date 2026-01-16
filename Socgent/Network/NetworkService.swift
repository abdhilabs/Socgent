//
//  NetworkService.swift
//  Socgent
//
//  Created by Abdhilabs on 16/01/26.
//

import Foundation
import Moya

actor NetworkService {
  static let shared = NetworkService()
  
  private init() {}
  
  func requestData(_ api: SocgentAPI) async throws -> (data: Data, statusCode: Int) {
    try await withCheckedThrowingContinuation { continuation in
      let provider = MoyaProvider<SocgentAPI>()
      provider.request(api) { result in
        switch result {
        case .success(let response):
          continuation.resume(returning: (response.data, response.statusCode))
        case .failure(let error):
          continuation.resume(throwing: error)
        }
      }
    }
  }
  
  func request<T: Decodable>(
    _ api: SocgentAPI,
    as type: T.Type,
    decoder: JSONDecoder = JSONDecoder()
  ) async throws -> T {
    let result = try await requestData(api)
    return try decoder.decode(T.self, from: result.data)
  }
}
