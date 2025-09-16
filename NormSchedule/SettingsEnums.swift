//
//  SettingsEnums.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 16.09.2025.
//

import Foundation
import SwiftUICore

enum Parity: String, CaseIterable, Identifiable {
    case none, even, odd

    var id: String { rawValue }

    var title: LocalizedStringKey {
        LocalizedStringKey(rawValue)
    }

    var intValue: Int {
        switch self {
        case .none:
            return 0
        case .even:
            return 1
        case .odd:
            return 2
        }
    }
}

enum DayTabBarPosition: String, CaseIterable, Identifiable {
    case top, bottom

    var id: String { rawValue }
    var title: LocalizedStringKey { LocalizedStringKey(rawValue) }
}

enum DayTabBarStyle: String, CaseIterable, Identifiable {
    case round, straight

    var id: String { rawValue }
    var title: LocalizedStringKey { LocalizedStringKey(rawValue) }
}

