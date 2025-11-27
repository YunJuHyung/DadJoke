//
//  AuthManager.swift
//  DadJoke
//
//  Created by Claude Code
//

import Foundation
import AuthenticationServices
import Supabase
import Combine

@MainActor
class AuthManager: NSObject, ObservableObject {
    static let shared = AuthManager()

    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false

    private override init() {
        super.init()
        Task {
            await checkAuthStatus()
        }
    }

    // MARK: - 로그인 상태 확인
    func checkAuthStatus() async {
        do {
            let session = try await SupabaseManager.shared.client.auth.session
            currentUser = session.user
            isAuthenticated = true
            print("✅ 로그인 상태: \(session.user.email ?? "이메일 없음")")
        } catch {
            isAuthenticated = false
            currentUser = nil
            print("ℹ️ 로그인되지 않음")
        }
    }

    // MARK: - Apple Sign In 시작
    func signInWithApple() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.email, .fullName]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    // MARK: - 로그아웃
    func signOut() async {
        do {
            try await SupabaseManager.shared.client.auth.signOut()
            isAuthenticated = false
            currentUser = nil

            // 알림 비활성화
            await NotificationManager.shared.disableNotifications()

            print("✅ 로그아웃 완료")
        } catch {
            print("❌ 로그아웃 실패: \(error)")
        }
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AuthManager: ASAuthorizationControllerDelegate {

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let idTokenData = credential.identityToken,
              let idToken = String(data: idTokenData, encoding: .utf8) else {
            print("❌ Apple Sign In 실패: 토큰을 가져올 수 없습니다")
            return
        }

        Task {
            do {
                isLoading = true

                // Supabase에 Apple ID 토큰으로 로그인
                let session = try await SupabaseManager.shared.client.auth.signInWithIdToken(
                    credentials: .init(
                        provider: .apple,
                        idToken: idToken
                    )
                )

                currentUser = session.user
                isAuthenticated = true

                // 로그인 성공 후 알림 권한 요청
                await NotificationManager.shared.requestAuthorization()

                print("✅ Apple Sign In 성공: \(session.user.email ?? "이메일 없음")")

                isLoading = false
            } catch {
                print("❌ Supabase 로그인 실패: \(error)")
                isLoading = false
            }
        }
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        print("❌ Apple Sign In 에러: \(error.localizedDescription)")
        isLoading = false
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AuthManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("No window found")
        }
        return window
    }
}
