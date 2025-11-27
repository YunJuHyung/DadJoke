//
//  SettingsView.swift
//  DadJoke
//
//  Created by Claude Code
//

import SwiftUI
import AuthenticationServices
internal import Auth

struct SettingsView: View {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var isNotificationEnabled = false

    var body: some View {
        ZStack {
            // 배경 그라데이션
            LinearGradient(
                gradient: Gradient(colors: [Color(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)), Color(#colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1))]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 30) {
                    // 헤더
                    VStack(spacing: 8) {
                        Text("👤")
                            .font(.system(size: 60))

                        Text("마이페이지")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .padding(.top, 60)

                    if authManager.isAuthenticated {
                        // 로그인 후 화면
                        loggedInView
                    } else {
                        // 로그인 전 화면
                        loginView
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .task {
            isNotificationEnabled = notificationManager.isAuthorized
        }
    }

    // MARK: - 로그인 전 화면
    private var loginView: some View {
        VStack(spacing: 30) {
            VStack(spacing: 16) {
                Text("로그인하고")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("매일 아침 개그 알림을 받아보세요!")
                    .font(.system(size: 18))
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)

            // Apple Sign In 버튼
            SignInWithAppleButton(
                onRequest: { request in
                    request.requestedScopes = [.email, .fullName]
                },
                onCompletion: { result in
                    // AuthManager에서 처리
                }
            )
            .signInWithAppleButtonStyle(.white)
            .frame(height: 50)
            .cornerRadius(25)
            .padding(.horizontal, 40)
            .onTapGesture {
                authManager.signInWithApple()
            }

            Text("로그인하지 않아도 개그는 볼 수 있어요\n알림만 받을 수 없습니다")
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.top, 20)
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white.opacity(0.2))
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        )
        .padding(.horizontal, 30)
    }

    // MARK: - 로그인 후 화면
    private var loggedInView: some View {
        VStack(spacing: 30) {
            // 유저 정보 카드
            VStack(spacing: 16) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)

                if let email = authManager.currentUser?.email {
                    Text(email)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.primary)
                } else {
                    Text("Apple 계정")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.primary)
                }

                Text("로그인 완료 확인용")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(30)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 5)
            )
            .padding(.horizontal, 30)

            // 알림 설정 카드
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Text("🔔 매일 아침 개그 알림")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)

                    Text("매일 오전 9시에 새로운 개그를 알려드립니다")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

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

                if let token = notificationManager.deviceToken, isNotificationEnabled {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("알림 활성화됨")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.green)
                    }
                }
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 5)
            )
            .padding(.horizontal, 30)

            // 로그아웃 버튼
            Button {
                Task {
                    await authManager.signOut()
                    isNotificationEnabled = false
                }
            } label: {
                Text("로그아웃")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.red.opacity(0.8))
                    )
            }
            .padding(.horizontal, 30)
            .padding(.top, 10)
        }
    }
}

#Preview {
    SettingsView()
}
