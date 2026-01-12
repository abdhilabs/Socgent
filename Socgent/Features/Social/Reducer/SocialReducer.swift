//
//  SocialReducer.swift
//  Socgent
//
//  Created by Abdhilabs on 10/01/26.
//

import ComposableArchitecture
import SwiftUI
import UIKit

@Reducer
struct SocialReducer {
  @Dependency(\.recentSocialDB) var recentSocialDB
  @Dependency(\.stylePreference) var stylePreference
  
  @ObservableState
  struct State: Equatable {
    var txtSocial: String = ""
    var errorMessage: String?
    var recentSocials: [Social] = []
    var isDarkStyle: Bool = false
  }
  
  enum Action: Equatable {
    case onAppear
    case onTextChanged(text: String)
    case onChipTapped(type: SocialType)
    case onSocialResponseFetched(response: Result<[Social], SocgentError>)
    case onItemSocialTapped(item: Social)
    case onItemSocialDeleted(id: IndexSet)
    case onToolbarThemeTapped
    case fetchCurrentTheme
    case clearError
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .run { send in
          await send(.fetchCurrentTheme)
          do {
            let socials = try recentSocialDB.fetchAll()
            await send(.onSocialResponseFetched(response: .success(socials)))
          } catch {
            await send(.onSocialResponseFetched(response: .failure(.swiftDataError(error))))
          }
        }
      case .onTextChanged(let text):
        state.txtSocial = text
        return .send(.clearError)
      case .onChipTapped(let type):
        switch type {
        case .shareX:
          // implement Share X behaviour later
          return .none
        case .whatsapp:
          return openToWhatsapp(state: &state)
        }
      case .onItemSocialTapped(let item):
        return .run { _ in
          switch item.type {
          case .shareX:
            break
          case .whatsapp:
            await MainActor.run {
              UIApplication.shared.openURLInBrowser(urlString: item.social)
            }
          }
        }
      case .onItemSocialDeleted(let id):
        let items = id.map { state.recentSocials[$0] }
        return .run { send in
          do {
            for item in items { try recentSocialDB.delete(item) }
            let socials = try recentSocialDB.fetchAll()
            await send(.onSocialResponseFetched(response: .success(socials)))
          } catch {
            await send(.onSocialResponseFetched(response: .failure(.swiftDataError(error))))
          }
        }
      case .onToolbarThemeTapped:
        let isDarkStyle = state.isDarkStyle
        return .run { send in
          await MainActor.run {
            stylePreference.save(isDarkStyle ? .light : .dark)
          }
          await send(.fetchCurrentTheme)
        }
      case .onSocialResponseFetched(let result):
        switch result {
        case .success(let datas):
          state.recentSocials = datas.sorted(by: { $0.updatedAt > $1.updatedAt })
        case .failure:
          state.recentSocials.removeAll()
        }
        return .none
      case .fetchCurrentTheme:
        let style = stylePreference.load()
        state.isDarkStyle = style == .dark
        return .none
      case .clearError:
        state.errorMessage = nil
        return .none
      }
    }
  }
  
  func openToWhatsapp(state: inout State) -> Effect<SocialReducer.Action> {
    let phoneNumber = state.txtSocial
    if let number = extractPhoneNumber(from: phoneNumber) {
      let urlString = "https://wa.me/\(number)"
      let newSocial = Social(social: urlString, type: .whatsapp, updatedAt: Date())
      return .run { send in
        do {
          try recentSocialDB.upsert(newSocial)
          let socials = try recentSocialDB.fetchAll()
          await send(.onSocialResponseFetched(response: .success(socials)))
        } catch {
          await send(.onSocialResponseFetched(response: .failure(.swiftDataError(error))))
        }
        await MainActor.run {
          UIApplication.shared.openURLInBrowser(urlString: urlString)
        }
      }
    } else {
      state.errorMessage = "Enter phone with country code (e.g. 628957845093)."
    }
    return .none
  }
  
  func extractPhoneNumber(from text: String) -> String? {
    let digits = text.filter { $0.isWholeNumber }
    guard digits.count >= 6 else { return nil }
    guard let firstChar = digits.first, firstChar != "0" else { return nil }
    return digits
  }
}
