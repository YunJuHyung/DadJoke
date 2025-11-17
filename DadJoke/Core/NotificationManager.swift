//
//  NotificationManager.swift
//  DadJoke
//
//  Created by Claude Code
//

import UserNotifications
import Foundation
import UIKit
import Combine

@MainActor
class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()

    @Published var isAuthorized = false
    @Published var deviceToken: String?

    private let notificationCenter = UNUserNotificationCenter.current()

    override private init() {
        super.init()
        notificationCenter.delegate = self
    }

    // MARK: - 권한 요청
    func requestAuthorization() async {
        do {
            let granted = try await notificationCenter.requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            isAuthorized = granted

            if granted {
                // 권한 승인 시 APNS 등록
                await registerForRemoteNotifications()
            }
        } catch {
            print("❌ 알림 권한 요청 실패: \(error)")
        }
    }

    // MARK: - APNS 등록
    func registerForRemoteNotifications() async {
        UIApplication.shared.registerForRemoteNotifications()
    }

    // MARK: - 디바이스 토큰 저장
    func saveDeviceToken(_ token: String) async {
        self.deviceToken = token

        // Supabase에 토큰 저장
        do {
            // 현재 로그인한 유저 ID 가져오기
            guard let userId = try await SupabaseManager.shared.client.auth.session.user.id else {
                print("❌ 로그인된 유저가 없습니다")
                return
            }

            struct DeviceTokenInsert: Encodable {
                let user_id: String
                let device_token: String
                let platform: String
                let is_active: Bool
                let updated_at: String
            }

            let tokenData = DeviceTokenInsert(
                user_id: userId.uuidString,
                device_token: token,
                platform: "ios",
                is_active: true,
                updated_at: ISO8601DateFormatter().string(from: Date())
            )

            try await SupabaseManager.shared.client
                .from("device_tokens")
                .upsert(tokenData)
                .execute()

            print("✅ 디바이스 토큰 저장 완료: \(token)")
        } catch {
            print("❌ 디바이스 토큰 저장 실패: \(error)")
        }
    }

    // MARK: - 알림 비활성화 (설정에서 토글 off 시)
    func disableNotifications() async {
        guard let token = deviceToken else { return }

        do {
            struct DeviceTokenUpdate: Encodable {
                let is_active: Bool
            }

            let update = DeviceTokenUpdate(is_active: false)

            try await SupabaseManager.shared.client
                .from("device_tokens")
                .update(update)
                .eq("device_token", value: token)
                .execute()

            print("✅ 알림 비활성화 완료")
        } catch {
            print("❌ 알림 비활성화 실패: \(error)")
        }
    }

    // MARK: - 알림 활성화 (설정에서 토글 on 시)
    func enableNotifications() async {
        guard let token = deviceToken else {
            // 토큰이 없으면 권한 요청
            await requestAuthorization()
            return
        }

        do {
            struct DeviceTokenUpdate: Encodable {
                let is_active: Bool
                let updated_at: String
            }

            let update = DeviceTokenUpdate(
                is_active: true,
                updated_at: ISO8601DateFormatter().string(from: Date())
            )

            try await SupabaseManager.shared.client
                .from("device_tokens")
                .update(update)
                .eq("device_token", value: token)
                .execute()

            print("✅ 알림 활성화 완료")
        } catch {
            print("❌ 알림 활성화 실패: \(error)")
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationManager: UNUserNotificationCenterDelegate {

    // 포그라운드에서도 알림 표시
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        return [.banner, .sound, .badge]
    }

    // 알림 탭 시 처리
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo

        // 개그 ID 추출
        if let gagId = userInfo["gag_id"] as? String {
            print("📱 알림 탭됨 - 개그 ID: \(gagId)")

            // DeepLink 처리 (특정 개그 화면으로 이동)
            NotificationCenter.default.post(
                name: NSNotification.Name("OpenGagDetail"),
                object: nil,
                userInfo: ["gag_id": gagId]
            )
        }
    }
}
