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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.modelContainer(for: GroupSched.self)
    }
}

