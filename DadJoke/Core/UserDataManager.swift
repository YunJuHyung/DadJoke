//
//  UserDataManager.swift
//  DadJoke
//
//  Created by Claude Code
//

import Foundation

// MARK: - 사용자 데이터 관리 (본 개그, 북마크)
class UserDataManager {
    static let shared = UserDataManager()

    private let defaults = UserDefaults.standard
    private let viewedGagsKey = "viewedGags"
    private let lastResetDateKey = "lastResetDate"
    private let bookmarkedGagsKey = "bookmarkedGags"
    private let likedGagsKey = "likedGags"

    private init() {
        checkAndResetIfNeeded()
    }

    // MARK: - 본 개그 관리

    // 오늘 본 개그 ID 목록 가져오기
    func getViewedGagIds() -> [Int] {
        return defaults.array(forKey: viewedGagsKey) as? [Int] ?? []
    }

    // 개그를 본 것으로 표시
    func markGagAsViewed(gagId: Int) {
        var viewedGags = getViewedGagIds()
        if !viewedGags.contains(gagId) {
            viewedGags.append(gagId)
            defaults.set(viewedGags, forKey: viewedGagsKey)
        }
    }

    // 매일 자정에 리셋되도록 확인
    private func checkAndResetIfNeeded() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastResetDate = defaults.object(forKey: lastResetDateKey) as? Date {
            let lastReset = calendar.startOfDay(for: lastResetDate)

            // 날짜가 바뀌었으면 본 개그 목록 초기화
            if today > lastReset {
                resetViewedGags()
            }
        } else {
            // 처음 실행하는 경우
            defaults.set(today, forKey: lastResetDateKey)
        }
    }

    private func resetViewedGags() {
        defaults.removeObject(forKey: viewedGagsKey)
        defaults.set(Date(), forKey: lastResetDateKey)
    }

    // MARK: - 북마크 관리

    // 북마크된 개그 ID 목록 가져오기
    func getBookmarkedGagIds() -> [Int] {
        return defaults.array(forKey: bookmarkedGagsKey) as? [Int] ?? []
    }

    // 북마크 토글 (추가/제거)
    func toggleBookmark(gagId: Int) -> Bool {
        var bookmarkedGags = getBookmarkedGagIds()

        if let index = bookmarkedGags.firstIndex(of: gagId) {
            // 이미 북마크되어 있으면 제거
            bookmarkedGags.remove(at: index)
            defaults.set(bookmarkedGags, forKey: bookmarkedGagsKey)
            return false
        } else {
            // 북마크 추가
            bookmarkedGags.append(gagId)
            defaults.set(bookmarkedGags, forKey: bookmarkedGagsKey)
            return true
        }
    }

    // 특정 개그가 북마크되어 있는지 확인
    func isBookmarked(gagId: Int) -> Bool {
        return getBookmarkedGagIds().contains(gagId)
    }

    // MARK: - 좋아요 관리

    // 좋아요한 개그 ID 목록 가져오기
    func getLikedGagIds() -> [Int] {
        return defaults.array(forKey: likedGagsKey) as? [Int] ?? []
    }

    // 좋아요 토글 (추가/제거)
    func toggleLike(gagId: Int) -> Bool {
        var likedGags = getLikedGagIds()

        if let index = likedGags.firstIndex(of: gagId) {
            // 이미 좋아요되어 있으면 제거
            likedGags.remove(at: index)
            defaults.set(likedGags, forKey: likedGagsKey)
            return false
        } else {
            // 좋아요 추가
            likedGags.append(gagId)
            defaults.set(likedGags, forKey: likedGagsKey)
            return true
        }
    }

    // 특정 개그가 좋아요되어 있는지 확인
    func isLiked(gagId: Int) -> Bool {
        return getLikedGagIds().contains(gagId)
    }
}
