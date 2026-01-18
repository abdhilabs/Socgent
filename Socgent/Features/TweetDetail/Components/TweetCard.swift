//
//  TweetCard.swift
//  Socgent
//
//  Created by Abdhilabs on 17/01/26.
//

import SwiftUI

struct TweetCardItem: Equatable {
  let urlPhoto: String
  let username: String
  let name: String
  var highlightText: String
  let text: String
  
  init(urlPhoto: String = "", username: String = "", name: String = "", text: String = "") {
    self.urlPhoto = urlPhoto
    self.username = username
    self.name = name
    self.highlightText = text
    self.text = text
  }
}

struct TweetCard: View {
  @Environment(\.appStyle) var style
  
  let item: TweetCardItem
  
  var body: some View {
    ZStack(alignment: .topTrailing) {
      Icon.product(.twitter, color: style.colors.text.primary)
      
      VStack(alignment: .center, spacing: 16) {
        Text(AttributedString(item.highlightText))
          .font(.caption2)
          .foregroundStyle(style.colors.text.primary)
          .multilineTextAlignment(.center)
          .fixedSize(horizontal: false, vertical: true)
        
        Text("by \(item.name)")
          .font(.callout)
          .italic()
          .foregroundStyle(style.colors.text.primary)
      }
      .padding(.top, 24)
      .frame(maxWidth: .infinity)
    }
    .padding(16)
    .frame(width: UIScreen.main.bounds.width)
    .background(style.colors.background.primary)
    .fixedSize()
  }
}

#Preview {
  TweetCard(item: TweetCardItem(
    username: "@mrdhip",
    name: "Abdhi P",
    text: "feeling good today!"
  ))
}
