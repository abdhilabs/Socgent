//
//  TweetDetailView.swift
//  Socgent
//
//  Created by Abdhilabs on 17/01/26.
//

import ComposableArchitecture
import SwiftUI

struct TweetDetailView: View {
  @Environment(\.presentationMode) private var presentationMode
  @Environment(\.appStyle) var style
  
  let store: StoreOf<TweetDetailReducer>
  
  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack {
        PagingHorizontal(
          items: TweetCardMode.allCases,
          currentIndex: viewStore.binding(
            get: { $0.selectedIndexMode },
            send: { return .onModeSelected(index: $0) }),
          content: { mode in
            switch mode {
            case .textOnly:
              TweetCard(item: viewStore.tweetDetail)
            case .full:
              TweetCard(item: viewStore.tweetDetail)
            }
          }
        )
        
        VStack(alignment: .leading, spacing: 0) {
          Text("Tweet")
            .foregroundColor(style.colors.text.secondary)
            .font(.subheadline)
          
          SelectableTextView(
            text: viewStore.tweetDetail.text,
            customActionTitle: "Highlight Tweet",
            onCustomAction: { text in
              viewStore.send(.onHighlightTweetSelected(text: text))
            }
          )
        }
        .padding(.horizontal, 16)
      }
      .background(style.colors.background.primary)
      .navigationTitle("Tweet Detail")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          if presentationMode.wrappedValue.isPresented {
            Button("Close") {
              presentationMode.wrappedValue.dismiss()
            }
          }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
          Button("Save") {
            Task {
              viewStore.send(.onSaveTapped)
            }
          }
        }
      }
      .task {
        await viewStore.send(.onAppear).finish()
      }
    }
  }
}

#Preview {
  TweetDetailView(store: Store(
    initialState: TweetDetailReducer.State(),
    reducer: { TweetDetailReducer() }
  ))
}
