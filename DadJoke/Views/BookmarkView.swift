//
//  BookmarkView.swift
//  DadJoke
//
//  Created by Claude Code
//

import SwiftUI

struct BookmarkView: View {
    @State private var bookmarkedGags: [Gag] = []
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            ZStack {
                // 배경 그라데이션
                LinearGradient(
                    gradient: Gradient(colors: [Color(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)), Color(#colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1))]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(2)
                } else if bookmarkedGags.isEmpty {
                    // 북마크가 없을 때
                    VStack(spacing: 20) {
                        Image(systemName: "bookmark.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.white)

                        Text("북마크한 개그가 없습니다")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                    }
                } else {
                    // 북마크 리스트
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(bookmarkedGags) { gag in
                                GagListItemView(gag: gag) {
                                    // 북마크 제거 시 리스트에서 삭제
                                    loadBookmarks()
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("북마크")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)), for: .navigationBar)
        }
        .task {
            loadBookmarks()
        }
    }

    private func loadBookmarks() {
        Task {
            isLoading = true
            let bookmarkedIds = UserDataManager.shared.getBookmarkedGagIds()

            if bookmarkedIds.isEmpty {
                bookmarkedGags = []
                isLoading = false
                return
            }

            // Supabase에서 북마크된 개그들 가져오기
            do {
                let allGags = try await GagAPIService.shared.fetchGags()
                bookmarkedGags = allGags.filter { bookmarkedIds.contains($0.id) }
                isLoading = false
            } catch {
                print("북마크 로드 실패: \(error)")
                isLoading = false
            }
        }
    }
}

// MARK: - 개그 리스트 아이템 뷰
struct GagListItemView: View {
    let gag: Gag
    let onBookmarkToggle: () -> Void

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 질문
            HStack(alignment: .top, spacing: 12) {
                Text("Q.")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.orange)

                Text(gag.title)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // 북마크 버튼
                Button(action: {
                    _ = UserDataManager.shared.updateBookmark(gagId: gag.id)
                    onBookmarkToggle()
                }) {
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.yellow)
                }
            }

            // 답변 토글 버튼
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(isExpanded ? "답변 숨기기" : "답변 보기")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                }
            }

            // 답변 (확장 시)
            if isExpanded {
                HStack(alignment: .top, spacing: 12) {
                    Text("A.")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.green)

                    Text(gag.content)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .transition(.opacity)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

#Preview {
    BookmarkView()
}
