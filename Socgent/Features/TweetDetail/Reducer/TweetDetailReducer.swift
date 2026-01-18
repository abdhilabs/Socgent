//
//  TweetDetailReducer.swift
//  Socgent
//
//  Created by Abdhilabs on 17/01/26.
//

import ComposableArchitecture
import SwiftUI
import UIKit

enum TweetCardMode: Int, Equatable, CaseIterable, Identifiable {
  var id: Self {
    self
  }
  
  case textOnly
  case full
}

@Reducer
struct TweetDetailReducer {
  @Dependency(\.recentSocialDB) var recentSocialDB
  @Dependency(\.xClient) var xClient
  
  @ObservableState
  struct State: Equatable {
    var selectedIndexMode = 0
    var tweetDetail = TweetCardItem()
  }
  
  enum Action: Equatable {
    case onAppear
    case onSaveTapped
    case onModeSelected(index: Int)
    case onHighlightTweetSelected(text: String)
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        let item = TweetCardItem(
          username: "@mrdhip",
          name: "Abdhi P",
          text: """
feeling good today! feeling good today! feeling good today! feeling good today! feeling good today! feeling good today!
feeling good today! feeling good today! feeling good today! feeling good today! feeling good today! feeling good today!
feeling good today! feeling good today! feeling good today! feeling good today! feeling good today! feeling good today!
feeling good today! feeling good today! feeling good today! feeling good today! feeling good today! feeling good today!
feeling good today! feeling good today! feeling good today! feeling good today! feeling good today! feeling good today!
"""
        )
        state.tweetDetail = item
        return .none
      case .onSaveTapped:
        return convertToTweetCardAsImage(from: state)
      case .onModeSelected(let index):
        state.selectedIndexMode = index
        return .none
      case .onHighlightTweetSelected(let text):
        state.tweetDetail.highlightText = text
        return .none
      }
    }
  }
  
  private func convertToTweetCardAsImage(from state: State) -> Effect<TweetDetailReducer.Action> {
    let mode = TweetCardMode(rawValue: state.selectedIndexMode) ?? .textOnly
    return .run { _ in
      let viewImage: UIImage
      switch mode {
      case .textOnly:
        let card = TweetCard(item: state.tweetDetail)
        viewImage = await card.convertToImage(width: UIScreen.main.bounds.width)
      case .full:
        let card = TweetCard(item: state.tweetDetail)
        viewImage = await card.convertToImage()
      }
      let isSaved = await ImageSaver.saveImage(for: viewImage)
      Log.info("Image is saved: \(isSaved)")
    }
  }
}

// func loadImage(url: URL) async throws -> UIImage {
//    let (data, _) = try await URLSession.shared.data(from: url)
//    return await Task.detached {
//        UIImage(data: data)!
//    }.value
// }
