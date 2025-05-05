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
    static var description = IntentDescription("Настройте что должен показывать виджет")

    @Parameter(title: "Показывать текущее занятие", default: true)
    var showCurrent: Bool

    @Parameter(title: "Показывать следующее занятие", default: true)
    var showNext: Bool

    @Parameter(title: "Показывать надписи, кроме названий", default: true)
    var showLabels: Bool

    @Parameter(title: "Показывать текущее и следующее занятия одновременно", default: true)
    var showBoth: Bool

    @Parameter(title: "Что показывать из пары", default: InfoField.time)
    var selectedInfoField: InfoField
}

enum InfoField: String, AppEnum {
    case teacher, time, place, type, subgroup, parity, importance

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Что показывать из пары"

    static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .teacher: "Преподаватель",
        .time: "Время конца/начала",
        .place: "Место",
        .type: "Тип занятия",
        .subgroup: "Подгруппа",
        .parity: "Четность (Неделя)",
        .importance: "Важность"
    ]
}
