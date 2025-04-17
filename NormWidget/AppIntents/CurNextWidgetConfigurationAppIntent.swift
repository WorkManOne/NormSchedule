//
//  CurNextWidgetAppIntent.swift
//  NormWidgetExtension
//
//  Created by Кирилл Архипов on 16.04.2025.
//

import Foundation
import AppIntents

struct CurNextWidgetConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Настройки виджета"
    static var description = IntentDescription("Выберите, какие занятия показывать")

    @Parameter(title: "Показывать текущее занятие", default: true)
    var showCurrent: Bool

    @Parameter(title: "Показывать следующее занятие", default: true)
    var showNext: Bool
}
