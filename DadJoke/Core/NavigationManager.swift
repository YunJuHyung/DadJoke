//
//  NavigationManager.swift
//  DadJoke
//
//  Created by Claude Code
//

import SwiftUI
import Combine

@MainActor
class NavigationManager: ObservableObject {
    @Published var selectedGagId: String?
    @Published var shouldNavigateToDetail = false

    func navigateToGagDetail(gagId: String) {
        self.selectedGagId = gagId
        self.shouldNavigateToDetail = true
    }

    func resetNavigation() {
        self.selectedGagId = nil
        self.shouldNavigateToDetail = false
    }
}
