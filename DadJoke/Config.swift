//
//  Config.swift
//  DadJoke
//
//  Created by Claude Code
//

import Foundation

enum Config {
    // xcconfig 파일에서 환경 변수 읽기
    // Build Settings에서 SUPABASE_URL과 SUPABASE_KEY를 설정해야 합니다.

    static var supabaseURL: String {
        guard let url = ProcessInfo.processInfo.environment["SUPABASE_URL"] else {
            fatalError("SUPABASE_URL이 설정되지 않았습니다. Config.xcconfig 파일을 확인하세요.")
        }
        return url
//        return "https://blbdlujzjkrrstudzxku.supabase.co"
    }

    static var supabaseKey: String {
        guard let key = ProcessInfo.processInfo.environment["SUPABASE_KEY"] else {
            fatalError("SUPABASE_KEY가 설정되지 않았습니다. Config.xcconfig 파일을 확인하세요.")
        }
        let cleanedKey = key
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: " ", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return cleanedKey
//        return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJsYmRsdWp6amtycnN0dWR6eGt1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI4NDg5NjcsImV4cCI6MjA3ODQyNDk2N30.3XySuKbc3l7A0WWuTmAK7AKDalrSE79hhW9EHD0JYsU"
    }
}
