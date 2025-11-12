//
//  File.swift
//  DadJoke
//
//  Created by 윤주형 on 11/12/25.
//

import Foundation
import Supabase

// MARK: - Supabase API Service
class GagAPIService {

    // 싱글톤 패턴
    static let shared = GagAPIService()

    private let supabase = SupabaseManager.shared.client

    private init() {}

    // MARK: - 전체 개그 가져오기
    func fetchGags() async throws -> [Gag] {
        print("fetch 확인")
        let response: [Gag] = try await supabase
            .from("gags")
            .select()
            .order("created_at", ascending: false)
            .execute()
            .value

        return response
    }

    // MARK: - 특정 개그 가져오기
    func fetchGag(id: Int) async throws -> Gag {
        let response: [Gag] = try await supabase
            .from("gags")
            .select()
            .eq("id", value: id)
            .execute()
            .value

        guard let gag = response.first else {
            throw APIError.notFound
        }

        return gag
    }

    // MARK: - 카테고리별 개그 가져오기
    func fetchGags(category: String) async throws -> [Gag] {
        let response: [Gag] = try await supabase
            .from("gags")
            .select()
            .eq("category", value: category)
            .order("created_at", ascending: false)
            .execute()
            .value

        return response
    }

    // MARK: - 랜덤 개그 가져오기
    func fetchRandomGag() async throws -> Gag {
        // Supabase에서 전체 개그를 가져온 후 랜덤 선택
        let allGags = try await fetchGags()

        guard let randomGag = allGags.randomElement() else {
            throw APIError.noData
        }

        return randomGag
    }

    // MARK: - 새 개그 추가하기 (pending_gags 테이블에 저장)
    func addGag(title: String, content: String, category: String) async throws {
        struct NewGag: Encodable {
            let title: String
            let content: String
            let category: String
        }

        let newGag = NewGag(title: title, content: content, category: category)

        // pending_gags 테이블에 저장 (승인 대기)
        try await supabase
            .from("pending_gags")
            .insert(newGag)
            .execute()
    }

    // MARK: - 좋아요 on/off
    func toggleLike(gagId: Int, isLiked: Bool) async throws {
        // 좋아요 증가 or 감소
        let delta = isLiked ? 1 : -1

        // 1️⃣ 현재 좋아요 수 가져오기
        struct LikeData: Decodable { let likes: Int }
        let current: LikeData = try await supabase
            .from("gags")
            .select("likes")
            .eq("id", value: gagId)
            .single()
            .execute()
            .value

        // 2️⃣ 좋아요 수 업데이트하기
        let newLikes = max(current.likes + delta, 0)

        // Use an Encodable struct to avoid 'Any cannot conform to Encodable' when updating
        struct UpdateLikes: Encodable { let likes: Int }
        let update = UpdateLikes(likes: newLikes)

        let updateResponse = try await supabase
            .from("gags")
            .update(update)
            .eq("id", value: gagId)
            .execute()

        print("✅ 좋아요 업데이트 완료: \(updateResponse)")
    }
}

// MARK: - API Error
enum APIError: Error, LocalizedError {
    case notFound
    case noData
    case networkError

    var errorDescription: String? {
        switch self {
        case .notFound:
            return "개그를 찾을 수 없습니다."
        case .noData:
            return "데이터가 없습니다."
        case .networkError:
            return "네트워크 오류가 발생했습니다."
        }
    }
}
