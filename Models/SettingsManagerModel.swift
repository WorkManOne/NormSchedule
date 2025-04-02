//
//  SettingsManagerModel.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 21.01.2025.
//

import Foundation
import SwiftUI

final class SettingsManager: Decodable, Encodable, ObservableObject {
    static var shared: SettingsManager = SettingsManager()

    @Published var isEvenWeek: Int {
        didSet {
            let defaults = UserDefaults.standard
            let encoder = JSONEncoder()
            if let settings = try? encoder.encode(self) {
                defaults.set(settings, forKey: "settings")
            }
        }
    }

    @Published var dayTabBarPosition: Bool {
        didSet {
            let defaults = UserDefaults.standard
            let encoder = JSONEncoder()
            if let settings = try? encoder.encode(self) {
                defaults.set(settings, forKey: "settings")
            }
        }
    }
    @Published var dayTabBarStyle: Bool {
        didSet {
            let defaults = UserDefaults.standard
            let encoder = JSONEncoder()
            if let settings = try? encoder.encode(self) {
                defaults.set(settings, forKey: "settings")
            }
        }
    }

    @Published var lastSwitchDate: Date {
        didSet {
            let defaults = UserDefaults.standard
            let encoder = JSONEncoder()
            if let settings = try? encoder.encode(self) {
                defaults.set(settings, forKey: "settings")
            }
        }
    }

    init() {
        let defaults = UserDefaults.standard
        if let data = defaults.object(forKey: "settings") as? Data, let settings = try? JSONDecoder().decode(SettingsManager.self, from: data) {
            self.isEvenWeek = settings.isEvenWeek
            self.dayTabBarPosition = settings.dayTabBarPosition
            self.dayTabBarStyle = settings.dayTabBarStyle
            self.lastSwitchDate = settings.lastSwitchDate
            print("settings init")
            return
        }
        else {
            self.isEvenWeek = 0
            self.dayTabBarPosition = true
            self.dayTabBarStyle = true
            self.lastSwitchDate = Date.now
        }
        updateParityIfNeeded()
    }

    private enum CodingKeys: String, CodingKey {
        case isEvenWeek
        case dayTabBarPosition
        case dayTabBarStyle
        case lastSwitchDate
    }

    required init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        isEvenWeek = try values.decode(Int.self, forKey: .isEvenWeek)
        dayTabBarPosition = try values.decode(Bool.self, forKey: .dayTabBarPosition)
        dayTabBarStyle = try values.decode(Bool.self, forKey: .dayTabBarStyle)
        lastSwitchDate = try values.decode(Date.self, forKey: .lastSwitchDate)
    }
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(isEvenWeek, forKey: .isEvenWeek)
        try values.encode(dayTabBarPosition, forKey: .dayTabBarPosition)
        try values.encode(dayTabBarStyle, forKey: .dayTabBarStyle)
        try values.encode(lastSwitchDate, forKey: .lastSwitchDate)
    }

    func recalcCurrDay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru-RU")
        dateFormatter.setLocalizedDateFormatFromTemplate("EEE")
        return dateFormatter.string(from: Date())
    }
    func updateParityIfNeeded() {
        print("called updateParityIfNeeded")
        guard isEvenWeek != 0 else { return } // Если "Нет" - ничего не делаем

        let calendar = Calendar.current
        let now = Date()

        let currentWeek = calendar.component(.weekOfYear, from: now)
        let lastWeek = calendar.component(.weekOfYear, from: lastSwitchDate)

        let weeksPassed = currentWeek - lastWeek
        guard weeksPassed != 0 else { return }

        if weeksPassed % 2 != 0 {
            isEvenWeek = (isEvenWeek == 1) ? 2 : 1
        }

        lastSwitchDate = now
    }
}
//
//import Foundation
//
//final class SettingsManager: ObservableObject {
//    static let shared = SettingsManager()
//
//    // Настройки с автоматическим сохранением
//    @UserDefault("isEvenWeek", defaultValue: 0)
//    var isEvenWeek: Int {
//        didSet { updateLastChangeDate() }
//    }
//
//    @UserDefault("dayTabBarPosition", defaultValue: true)
//    var dayTabBarPosition: Bool
//
//    @UserDefault("dayTabBarStyle", defaultValue: true)
//    var dayTabBarStyle: Bool
//
//    @UserDefault("lastSwitchDate", defaultValue: Date())
//    private var lastSwitchDate: Date
//
//    private init() {
//        updateParityIfNeeded()
//    }
//
//    // Проверка и обновление чётности недели
//    func updateParityIfNeeded() {
//        guard isEvenWeek != 0 else { return }
//
//        let calendar = Calendar.current
//        let now = Date()
//
//        // Проверяем, была ли уже смена на этой неделе
//        if calendar.isDate(now, equalTo: lastSwitchDate, toGranularity: .weekOfYear) {
//            return
//        }
//
//        // Вычисляем сколько полных недель прошло
//        let weeksPassed = calendar.dateComponents([.weekOfYear], from: lastSwitchDate, to: now).weekOfYear ?? 0
//
//        // Меняем чётность только если прошло нечётное число недель
//        if weeksPassed % 2 != 0 {
//            isEvenWeek = isEvenWeek == 1 ? 2 : 1
//        }
//
//        lastSwitchDate = now
//    }
//
//    // Форматирование дня недели
//    func currentWeekdayName() -> String {
//        let formatter = DateFormatter()
//        formatter.locale = Locale(identifier: "ru-RU")
//        formatter.dateFormat = "EEE"
//        return formatter.string(from: Date())
//    }
//
//    private func updateLastChangeDate() {
//        lastSwitchDate = Date()
//    }
//}
//
//// Property wrapper для автоматического сохранения в UserDefaults
//@propertyWrapper
//struct UserDefault<T: Codable> {
//    private let key: String
//    private let defaultValue: T
//
//    init(_ key: String, defaultValue: T) {
//        self.key = key
//        self.defaultValue = defaultValue
//    }
//
//    var wrappedValue: T {
//        get {
//            guard let data = UserDefaults.standard.data(forKey: key),
//                  let value = try? JSONDecoder().decode(T.self, from: data) else {
//                return defaultValue
//            }
//            return value
//        }
//        set {
//            if let encoded = try? JSONEncoder().encode(newValue) {
//                UserDefaults.standard.set(encoded, forKey: key)
//            }
//        }
//    }
//}
