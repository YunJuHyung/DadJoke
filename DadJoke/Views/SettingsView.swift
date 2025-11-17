//
//  SettingsView.swift
//  DadJoke
//
//  Created by Claude Code
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var isNotificationEnabled = false

    var body: some View {
        ZStack {
            // 배경 그라데이션 (ContentView와 동일)
            LinearGradient(
                gradient: Gradient(colors: [Color(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)), Color(#colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1))]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                // 헤더
                VStack(spacing: 8) {
                    Text("⚙️")
                        .font(.system(size: 60))

                    Text("설정")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .padding(.top, 60)

                Spacer()

                // 알림 설정 카드
                VStack(spacing: 30) {
                    VStack(spacing: 16) {
                        Text("매일 아침 개그 알림")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)

                        Text("매일 오전 9시에 새로운 개그를 알려드립니다")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    // 토글 스위치
                    Toggle("", isOn: $isNotificationEnabled)
                        .labelsHidden()
                        .scaleEffect(1.5)
                        .onChange(of: isNotificationEnabled) { newValue in
                            Task {
                                if newValue {
                                    await notificationManager.enableNotifications()
                                } else {
                                    await notificationManager.disableNotifications()
                                }
                            }
                        }

                    // 상태 표시
                    if let token = notificationManager.deviceToken, isNotificationEnabled {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("알림 활성화됨")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.green)
                        }
                    }
                }
                .padding(40)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                )
                .padding(.horizontal, 40)

                Spacer()
            }
        }
        .task {
            // 설정 화면 진입 시 권한 상태 확인
            isNotificationEnabled = notificationManager.isAuthorized
        }
    }
}

#Preview {
    SettingsView()
}
