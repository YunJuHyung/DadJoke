//
//  AppDelegate.swift
//  DadJoke
//
//  Created by Claude Code
//

import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        // 알림 권한 요청
        Task {
            await NotificationManager.shared.requestAuthorization()
        }

        return true
    }

    // MARK: - APNS 토큰 등록 성공
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("📱 APNS Token: \(token)")

        // Supabase에 저장
        Task {
            await NotificationManager.shared.saveDeviceToken(token)
        }
    }

    // MARK: - APNS 토큰 등록 실패
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("❌ APNS 등록 실패: \(error)")
    }
}
