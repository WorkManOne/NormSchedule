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
    
    @ObservedObject var provider = WCProvider.shared
    @ObservedObject var settingsManager = SettingsManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.modelContainer(for: GroupSched.self)
            .environmentObject(provider)
            .environmentObject(settingsManager)
    }
}

