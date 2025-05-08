//
//  SettingsManagerModel.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 21.01.2025.
//

import Foundation
import SwiftUI

final class SettingsManager: Codable, ObservableObject {
    static var shared: SettingsManager = SettingsManager()

    @Published var isEvenWeek: Int {
        didSet {
            saveSettings()
        }
    }

    @Published var dayTabBarPosition: Bool {
        didSet {
            saveSettings()
        }
    }
    @Published var dayTabBarStyle: Bool {
        didSet {
            saveSettings()
        }
    }

    @Published var lastSwitchDate: Date {
        didSet {
            saveSettings()
        }
    }

    init() {
        if let data = UserDefaults.standard.data(forKey: "settings"),
           let loaded = try? JSONDecoder().decode(SettingsManager.self, from: data) {
            self.isEvenWeek = loaded.isEvenWeek
            self.dayTabBarPosition = loaded.dayTabBarPosition
            self.dayTabBarStyle = loaded.dayTabBarStyle
            self.lastSwitchDate = loaded.lastSwitchDate
            print("SettingsManager: loaded from UserDefaults")
        } else {
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

    private func saveSettings() {
        DispatchQueue.global(qos: .utility).async {
            let encoder = JSONEncoder()
            guard let data = try? encoder.encode(self) else { return }
            UserDefaults.standard.set(data, forKey: "settings")
        }
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
