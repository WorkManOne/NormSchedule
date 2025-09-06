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
        .modelContainer(modelContainer)
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

    private var modelContainer: ModelContainer = {
        do {
            let needsMigration = !UserDefaults.standard.bool(forKey: "appDataMigratedToUUID")

            if needsMigration {
                // Если нужна миграция, удаляем старую схему и создаем новую
                let schema = Schema([GroupSched.self])
                let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

                // Пытаемся удалить старый файл базы данных
                let container = try ModelContainer(for: schema, configurations: [configuration])

                // Очищаем все данные
                let context = ModelContext(container)
                try context.delete(model: GroupSched.self)

                // Помечаем как мигрированное
                UserDefaults.standard.set(true, forKey: "appDataMigratedToUUID")
                return container
            } else {
                // Обычная инициализация
                return try ModelContainer(for: GroupSched.self)
            }
        } catch {
            // Если произошла ошибка, создаем in-memory контейнер
            print("Error creating model container: \(error)")
            let schema = Schema([GroupSched.self])
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return try! ModelContainer(for: schema, configurations: [configuration])
        }
    }()
}

