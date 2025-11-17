//
//  GagViewModel.swift
//  DadJoke
//
//  Created by Claude Code
//

import Foundation
import SwiftUI
import Combine

@MainActor
class GagViewModel: ObservableObject {
    @Published var allGags: [Gag] = []
    @Published var availableGags: [Gag] = []
    @Published var currentGag: Gag?
    @Published var isAnswerRevealed = false
    @Published var isAnimating = false
    @Published var isLiked = false
    @Published var isBookmarked = false
    @Published var isLoading = true

    // 서비스 인스턴스
    private let userDataManager = UserDataManager.shared
    private let gagAPIService = GagAPIService.shared

    // 개그 데이터 로드 (앱 시작 시 한 번만)
    func fetchGags() async {
        guard allGags.isEmpty else { return } // 이미 로드했으면 스킵

        do {
            allGags = try await gagAPIService.fetchGags()
            loadNextGag()
            isLoading = false
        } catch {
            print("개그 데이터 로드 실패: \(error)")
            isLoading = false
        }
    }

    // 다음 개그 로드
    func loadNextGag() {
        // 오늘 본 개그 목록 가져오기
        let viewedGagIds = userDataManager.getViewedGagIds()

        // 아직 보지 않은 개그 필터링
        availableGags = allGags.filter { !viewedGagIds.contains($0.id) }

        // 다음 개그 선택
        if let nextGag = availableGags.randomElement() {
            currentGag = nextGag
            // 북마크 상태 업데이트
            isBookmarked = userDataManager.isBookmarked(gagId: nextGag.id)
            // 좋아요 상태 업데이트
            isLiked = userDataManager.isLiked(gagId: nextGag.id)
            print(isLiked)
            // 답변 상태 초기화
            isAnswerRevealed = false
        } else {
            currentGag = nil
        }
    }

    // 정답 확인
    func revealAnswer() {
        guard let gag = currentGag else { return }

        // 답변을 확인하면 개그를 본 것으로 표시
        print("정답 확인")
        userDataManager.markGagAsViewed(gagId: gag.id)

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isAnswerRevealed = true
        }
    }

    // 다음 개그로 이동
    func moveToNextGag() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isAnimating = true
        }

        loadNextGag()
        print("다음 개그 확인")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation {
                self.isAnimating = false
            }
        }
    }

    // 좋아요 버튼 액션
    func likeGag() {
        guard let gag = currentGag else { return }

        // 1. 로컬 상태 업데이트
        isLiked = userDataManager.updateLike(gagId: gag.id)

        // 2. Supabase 데이터베이스도 업데이트
        Task {
            do {
                try await gagAPIService.toggleLike(gagId: gag.id, isLiked: isLiked)
                print("✅ Supabase 좋아요 업데이트 성공")
            } catch {
                print("❌ Supabase 좋아요 업데이트 실패:", error)
                // 실패 시 로컬 상태 롤백
                isLiked = userDataManager.updateLike(gagId: gag.id)
            }
        }
    }

    // 북마크 버튼 액션
    func bookmarkGag() {
        guard let gag = currentGag else { return }
        isBookmarked = userDataManager.updateBookmark(gagId: gag.id)
    }

    // 특정 개그 로드 (알림 딥링크용)
    func loadSpecificGag(id: Int) async {
        do {
            let gag = try await gagAPIService.fetchGag(id: id)
            currentGag = gag
            isBookmarked = userDataManager.isBookmarked(gagId: gag.id)
            isLiked = userDataManager.isLiked(gagId: gag.id)
            isAnswerRevealed = false
            print("✅ 알림에서 개그 로드 완료: \(gag.title)")
        } catch {
            print("❌ 개그 로드 실패: \(error)")
        }
    }
}
