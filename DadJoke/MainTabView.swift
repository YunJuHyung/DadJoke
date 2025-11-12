//
//  MainTabView.swift
//  DadJoke
//
//  Created by Claude Code
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            // 홈 탭
            ContentView()
                .tabItem {
                    Label("홈", systemImage: "house.fill")
                }

            // 북마크 탭
            BookmarkView()
                .tabItem {
                    Label("북마크", systemImage: "bookmark.fill")
                }

            // 개그 추가 탭
            AddGagView()
                .tabItem {
                    Label("추가", systemImage: "plus.circle.fill")
                }
        }
        .accentColor(.blue)
    }
}

#Preview {
    MainTabView()
}
