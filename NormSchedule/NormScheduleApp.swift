//
//  NormScheduleApp.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 14.03.2024.
//

import SwiftUI
import SwiftData

@main
struct NormScheduleApp: App {
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false
    @ObservedObject var provider = WCProvider.shared
    @ObservedObject var settingsManager = SettingsManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .fullScreenCover(isPresented: .constant(!onboardingCompleted), content: {
                    OnboardingView {
                        onboardingCompleted = true
                    }
                })
        }
        .modelContainer(for: GroupSched.self)
        .environmentObject(provider)
        .environmentObject(settingsManager)
    }
}

