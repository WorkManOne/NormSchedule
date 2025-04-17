//
//  WidgetProvider.swift
//  NormWidgetExtension
//
//  Created by Кирилл Архипов on 15.04.2025.
//

import Foundation
import WidgetKit
import AppIntents

struct CurNextWidgetProvider: AppIntentTimelineProvider {
    typealias Entry = CurNextWidgetEntry

    typealias Intent = CurNextWidgetConfigurationAppIntent

    func placeholder(in context: Context) -> Entry {
        CurNextWidgetEntry(date: .now,
                           currentLesson: Lesson(timeStart: 30000, timeEnd: 32000, type: "практ.", subgroup: "2", parity: [:], name: "Программирование и конфигурирование в компьютерных сетях", teacher: "Кабанова Любовь Александровна", place: "12 корпус 414 ауд."),
                           nextLesson: Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"),
                           configuration: CurNextWidgetConfigurationAppIntent())
    }

    func snapshot(for configuration: Intent, in context: Context) async -> Entry {
        let entry =
        CurNextWidgetEntry(date: .now,
                           currentLesson: Lesson(timeStart: 30000, timeEnd: 32000, type: "практ.", subgroup: "2", parity: [:], name: "Программирование и конфигурирование в компьютерных сетях", teacher: "Кабанова Любовь Александровна", place: "12 корпус 414 ауд."),
                           nextLesson: Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"),
                           configuration: configuration)
        return entry
    }

    func timeline(for configuration: Intent, in context: Context) async -> Timeline<Entry> {
        var entries: [CurNextWidgetEntry] = []

        let entry =
        CurNextWidgetEntry(date: .now,
                           currentLesson: Lesson(timeStart: 30000, timeEnd: 32000, type: "практ.", subgroup: "2", parity: [:], name: "Программирование и конфигурирование в компьютерных сетях", teacher: "Кабанова Любовь Александровна", place: "12 корпус 414 ауд."),
                           nextLesson: Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"),
                           configuration: configuration)
        entries.append(entry)

        let timeline = Timeline(entries: entries, policy: .atEnd)
        return timeline
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}
