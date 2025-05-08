//
//  NormScheduleCompanionApp.swift
//  NormScheduleCompanion Watch App
//
//  Created by Кирилл Архипов on 03.03.2025.
//

import SwiftUI

@main
struct NormScheduleCompanion_Watch_AppApp: App {

    @ObservedObject var provider = WCProvider.shared
    @ObservedObject var settingsManager = SettingsManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environmentObject(provider)
        .environmentObject(settingsManager)
    }
}
