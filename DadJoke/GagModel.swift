//
//  GagModel.swift
//  DadJoke
//
//  Created by 윤주형 on 11/6/25.
//

import Foundation

// MARK: - 개그 모델
struct Gag: Codable, Identifiable {
    let id: Int
    let title: String
    let content: String
    let category: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, title, content, category
        case createdAt = "created_at"
    }
}

// MARK: - API Response 모델
struct GagResponse: Codable {
    let gags: [Gag]
    let totalCount: Int

    enum CodingKeys: String, CodingKey {
        case gags
        case totalCount = "total_count"
    }
}

// MARK: - Mock API Service
class MockGagAPIService {

    // 싱글톤 패턴 (선택사항)
    static let shared = MockGagAPIService()

    private init() {}

    // Mock 개그 데이터
    private let mockGags: [Gag] = [
        Gag(
            id: 1,
            title: "문어가 운동을 하면?",
            content: "헬스장이 아니라 '웰스'장! 🐙",
            category: "동물",
            createdAt: Date()
        ),
        Gag(
            id: 2,
            title: "김밥이 넘어지면?",
            content: "김밥말이! 🍱",
            category: "음식",
            createdAt: Date()
        ),
        Gag(
            id: 3,
            title: "돼지가 요리를 하면?",
            content: "포크를 사용하겠지! 🐷",
            category: "동물",
            createdAt: Date()
        ),
        Gag(
            id: 4,
            title: "고양이가 사는 나라는?",
            content: "냥골! 🐱",
            category: "동물",
            createdAt: Date()
        ),
        Gag(
            id: 5,
            title: "소가 웃으면?",
            content: "우하하! 🐮",
            category: "동물",
            createdAt: Date()
        ),
        Gag(
            id: 6,
            title: "빵이 웃으면?",
            content: "빵 터진다! 🍞",
            category: "음식",
            createdAt: Date()
        ),
        Gag(
            id: 7,
            title: "개가 얼음을 깨면?",
            content: "아이스브레이킹! 🐕",
            category: "동물",
            createdAt: Date()
        ),
        Gag(
            id: 8,
            title: "닭이 카페에 가면?",
            content: "닭다방! 🐔",
            category: "동물",
            createdAt: Date()
        ),
        Gag(
            id: 9,
            title: "엄마가 딸한테 라면 끓여주면서\n'라면이 익을 때까지 기다려'\n라고 했을 때 딸의 대답은?",
            content: "넵! 기다면!\n(기다려 + 라면) 😂",
            category: "일상",
            createdAt: Date()
        ),
        Gag(
            id: 10,
            title: "세계에서 가장 가난한 왕은?\n힌트: 돈이 한 푼도 없어요",
            content: "무일푼!\n(무일(無一) + 푼(penny)) 👑",
            category: "말장난",
            createdAt: Date()
        ),
        Gag(
            id: 11,
            title: "공부를 제일 안 하는 나라는?\n학생들이 공부를 정말 싫어한다고 해요",
            content: "네팔!\n(네! 팔자다!) 📚❌",
            category: "말장난",
            createdAt: Date()
        )
    ]

    // MARK: - 전체 개그 가져오기
    func fetchGags() async throws -> GagResponse {
        // 네트워크 지연 시뮬레이션
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1초

        return GagResponse(
            gags: mockGags,
            totalCount: mockGags.count
        )
    }

    // MARK: - 특정 개그 가져오기
    func fetchGag(id: Int) async throws -> Gag {
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5초

        guard let gag = mockGags.first(where: { $0.id == id }) else {
            throw APIError.notFound
        }

        return gag
    }

    // MARK: - 카테고리별 개그 가져오기
    func fetchGags(category: String) async throws -> GagResponse {
        try await Task.sleep(nanoseconds: 1_000_000_000)

        let filteredGags = mockGags.filter { $0.category == category }

        return GagResponse(
            gags: filteredGags,
            totalCount: filteredGags.count
        )
    }

    // MARK: - 랜덤 개그 가져오기
    func fetchRandomGag() async throws -> Gag {
        try await Task.sleep(nanoseconds: 500_000_000)

        guard let randomGag = mockGags.randomElement() else {
            throw APIError.noData
        }

        return randomGag
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
