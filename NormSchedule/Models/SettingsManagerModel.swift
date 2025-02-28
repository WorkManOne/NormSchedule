//
//  SettingsManagerModel.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 21.01.2025.
//

import Foundation

class SettingsManager: Decodable, Encodable, ObservableObject {
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

    init() {
        let defaults = UserDefaults.standard
        if let data = defaults.object(forKey: "settings") as? Data {
            let decoder = JSONDecoder()
            if let settings = try? decoder.decode(SettingsManager.self, from: data) {
                self.isEvenWeek = settings.isEvenWeek
                self.dayTabBarPosition = settings.dayTabBarPosition
                return
            }
            else {
                self.isEvenWeek = 0
                self.dayTabBarPosition = true
            }
        }
        else {
            self.isEvenWeek = 0
            self.dayTabBarPosition = true
        }

    }

    private enum CodingKeys: String, CodingKey {
            case isEvenWeek
            case dayTabBarPosition
    }

    required init(from decoder:Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            isEvenWeek = try values.decode(Int.self, forKey: .isEvenWeek)
            dayTabBarPosition = try values.decode(Bool.self, forKey: .dayTabBarPosition)
    }
    public func encode(to encoder: Encoder) throws {
            var values = encoder.container(keyedBy: CodingKeys.self)
            try values.encode(isEvenWeek, forKey: .isEvenWeek)
            try values.encode(dayTabBarPosition, forKey: .dayTabBarPosition)
    }

    func recalcCurrDay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru-RU")
        dateFormatter.setLocalizedDateFormatFromTemplate("EEE")
        return dateFormatter.string(from: Date())
    }
}
