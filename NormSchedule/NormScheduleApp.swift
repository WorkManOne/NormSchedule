//
//  NormScheduleApp.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 14.03.2024.
//

import SwiftUI
import SwiftData
import YandexMobileAds
import AppTrackingTransparency

@main
struct NormScheduleApp: App {
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false
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
        .environmentObject(settingsManager)
    }

    init() {
        requestTrackingAndInitializeAdsIfNeeded()
    }

    func requestTrackingAndInitializeAdsIfNeeded() {
        let status = ATTrackingManager.trackingAuthorizationStatus

        if status == .notDetermined {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                ATTrackingManager.requestTrackingAuthorization { newStatus in
                    print("ATT status: \(newStatus)")
                    MobileAds.initializeSDK()
                }
            }
        } else {
            MobileAds.initializeSDK()
        }
    }
}

