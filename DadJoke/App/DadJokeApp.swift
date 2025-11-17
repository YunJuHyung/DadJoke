//
//  DadJokeApp.swift
//  DadJoke
//
//  Created by 윤주형 on 11/6/25.
//

import SwiftUI

@main
struct DadJokeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var navigationManager = NavigationManager()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(navigationManager)
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenGagDetail"))) { notification in
                    if let gagId = notification.userInfo?["gag_id"] as? String {
                        navigationManager.navigateToGagDetail(gagId: gagId)
                    }
                }
        }
    }
}
