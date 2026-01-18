//
//  PagingHorizontal.swift
//  Socgent
//
//  Created by Abdhilabs on 17/01/26.
//

import SwiftUI

struct PagingHorizontal<Item: Identifiable, Content: View>: View {
  private let items: [Item]
  @Binding private var currentIndex: Int
  private let showsIndicators: Bool
  private let content: (Item) -> Content
  
  @State private var currentID: Item.ID?
  
  init(
    items: [Item],
    currentIndex: Binding<Int>,
    showsIndicators: Bool = false,
    @ViewBuilder content: @escaping (Item) -> Content
  ) {
    self.items = items
    self._currentIndex = currentIndex
    self.showsIndicators = showsIndicators
    self.content = content
  }
  
  var body: some View {
    ScrollView(.horizontal, showsIndicators: showsIndicators) {
      HStack(spacing: 0) {
        ForEach(items) { item in
          content(item)
            .containerRelativeFrame(.horizontal)
        }
      }
      .scrollTargetLayout()
    }
    .scrollTargetBehavior(.paging)
    .scrollPosition(id: $currentID)
    .onAppear {
      currentID = items[safe: currentIndex]?.id ?? items.first?.id
    }
    .onChange(of: currentID) { _, newValue in
      guard let newValue else { return }
      if let index = items.firstIndex(where: { $0.id == newValue }), index != currentIndex {
        currentIndex = index
      }
    }
    .onChange(of: currentIndex) { _, newValue in
      guard items.indices.contains(newValue) else { return }
      let newID = items[newValue].id
      if newID != currentID {
        currentID = newID
      }
    }
  }
}

private extension Array {
  subscript(safe index: Int) -> Element? {
    indices.contains(index) ? self[index] : nil
  }
}

#Preview {
  struct DemoItem: Identifiable {
    let id = UUID()
    let color: Color
    let title: String
  }
  
  @State var index = 0
  let items = [
    DemoItem(color: .red, title: "Page 1"),
    DemoItem(color: .green, title: "Page 2"),
    DemoItem(color: .blue, title: "Page 3")
  ]
  
  return PagingHorizontal(items: items, currentIndex: $index) { item in
    TweetCard(item: TweetCardItem(
      username: "@mrdhip",
      name: "Abdhi P",
      text: "feeling good today!"
    ))
    .background {
      Rectangle()
        .fill(item.color)
    }
  }
}
