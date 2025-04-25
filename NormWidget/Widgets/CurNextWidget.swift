//
//  NormWidget.swift
//  NormWidget
//
//  Created by Кирилл Архипов on 15.04.2025.
//

import WidgetKit
import SwiftUI
import AppIntents

struct CurNextWidgetEntry: TimelineEntry {
    var date: Date
    let currentLesson: Lesson?
    let nextLesson: Lesson?
    let nextTitle: String?
    let configuration: CurNextWidgetConfigurationAppIntent
}

struct CurNextWidget: Widget {
    let kind: String = "CurNextWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: CurNextWidgetConfigurationAppIntent.self,
            provider: CurNextWidgetProvider()
        ) { entry in
            if #available(iOS 17.0, *) {
                CurNextWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                CurNextWidgetView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Ближайшие занятия")
        .description("Настраиваемый виджет текущего и/или следующего занятий.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
    }
}

#Preview(as: .systemSmall) {
    CurNextWidget()
} timeline: {
    CurNextWidgetEntry(date: .now,
                       currentLesson: Lesson(timeStart: 30000, timeEnd: 32000, type: "практ.", subgroup: "2", parity: [:], name: "Программирование и конфигурирование в компьютерных сетях", teacher: "Кабанова Любовь Александровна", place: "12 корпус 414 ауд."),
                       nextLesson: Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"), nextTitle: "Далее", configuration: CurNextWidgetConfigurationAppIntent())
    CurNextWidgetEntry(date: .now,
                       currentLesson: Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"),
                       nextLesson: Lesson(timeStart: 45000, timeEnd: 50000, type: "лекция.", subgroup: "", parity: [:], name: "Математическая логика", teacher: "Молчанов", place: "12 корпус 420"), nextTitle: "Далее", configuration: CurNextWidgetConfigurationAppIntent())
    CurNextWidgetEntry(date: .now,
                       currentLesson: Lesson(timeStart: 45000, timeEnd: 50000, type: "лекция.", subgroup: "", parity: [:], name: "Математическая логика", teacher: "Молчанов", place: "12 корпус 420"),
                       nextLesson: nil, nextTitle: "Далее", configuration: CurNextWidgetConfigurationAppIntent())
    CurNextWidgetEntry(date: .now,
                       currentLesson: Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"),
                       nextLesson: nil, nextTitle: nil, configuration: CurNextWidgetConfigurationAppIntent())
    CurNextWidgetEntry(date: .now,
                       currentLesson: nil,
                       nextLesson: Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"), nextTitle: "Далее", configuration: CurNextWidgetConfigurationAppIntent())
    CurNextWidgetEntry(date: .now,
                       currentLesson: nil,
                       nextLesson: Lesson(timeStart: 45000, timeEnd: 50000, type: "лекция.", subgroup: "", parity: [:], name: "Математическая логика", teacher: "Молчанов", place: "12 корпус 420"), nextTitle: "Далее", configuration: CurNextWidgetConfigurationAppIntent())
    CurNextWidgetEntry(date: .now,
                       currentLesson: nil,
                       nextLesson: nil, nextTitle: "Далее", configuration: CurNextWidgetConfigurationAppIntent())
}
