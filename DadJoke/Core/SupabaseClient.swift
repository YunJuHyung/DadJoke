//
//  SupabaseClient.swift
//  DadJoke
//
//  Created by Claude Code
//

import Foundation
import Supabase

// MARK: - Supabase 클라이언트 설정
class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        // Config.xcconfig 파일에서 환경 변수 읽기
        let supabaseURL = Config.supabaseURL
        let supabaseKey = Config.supabaseKey

        self.client = SupabaseClient(
            supabaseURL: URL(string: supabaseURL)!,
            supabaseKey: supabaseKey
        )
    }
}
