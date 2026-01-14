//
//  SocialView.swift
//  Socgent
//
//  Created by Abdhilabs on 10/01/26.
//

import ComposableArchitecture
import SwiftUI

struct SocialView: View {
  @Environment(\.appStyle) var style
  
  let store: StoreOf<SocialReducer>
  
  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      NavigationStack {
        VStack(alignment: .leading, spacing: 16) {
          VStack(alignment: .leading, spacing: 8) {
            Text("social.prompt.title".localized)
              .font(.body)
              .bold()
              .foregroundStyle(style.colors.text.primary)
            
            TextField("social.placeholder.input".localized, text: viewStore.binding(
              get: { $0.txtSocial },
              send: { return .onTextChanged(text: $0) }))
            .textFieldStyle(.roundedBorder)
            .font(.caption)
            .preferredColorScheme(viewStore.isDarkStyle ? .dark : .light)
            
            if let errorMessage = viewStore.errorMessage {
              Text(errorMessage)
                .font(.caption)
                .foregroundStyle(style.colors.content.danger)
            }
          }
          
          LazyVGrid(
            columns: Array(
              repeating: GridItem(.flexible()),
              count: 2
            ),
            alignment: .leading,
            spacing: 8
          ) {
            ForEach(SocialType.allCases, id: \.self) { chip in
              Chip(
                style: Chip.Style(variant: .label(text: chip.label), fitContent: false),
                action: { viewStore.send(.onChipTapped(type: chip)) })
            }
          }
          .isHidden(viewStore.txtSocial.isEmpty)
          
          VStack(alignment: .leading, spacing: 0) {
            if viewStore.recentSocials.isNotEmpty {
              Text("social.recent.title".localized)
                .foregroundColor(style.colors.text.secondary)
                .font(.subheadline)
            }
            
            List {
              ForEach(viewStore.recentSocials) { social in
                Socialtem(item: social)
                  .listRowInsets(EdgeInsets())
                  .listRowBackground(Color.clear)
                  .onTapGesture {
                    viewStore.send(.onItemSocialTapped(item: social))
                  }
              }
              .onDelete { id in
                viewStore.send(.onItemSocialDeleted(id: id))
              }
            }
            .listStyle(.inset)
            .scrollContentBackground(.hidden)
            .scrollBounceBehavior(.basedOnSize)
          }
        }
        .padding(.horizontal, 16)
        .background(style.colors.background.primary)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .topBarTrailing) {
            Button {
              viewStore.send(.onToolbarThemeTapped)
            } label: {
              Image(systemName: viewStore.isDarkStyle ? "sun.max" : "moon")
            }
          }
        }
      }
      .onAppear {
        viewStore.send(.onAppear)
      }
    }
  }
}

#Preview {
  SocialView(store: Store(
    initialState: SocialReducer.State(),
    reducer: { SocialReducer() }
  ))
}
