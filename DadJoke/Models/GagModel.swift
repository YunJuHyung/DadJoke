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
    let likes: Int

    enum CodingKeys: String, CodingKey {
        case id, title, content, category, likes
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
