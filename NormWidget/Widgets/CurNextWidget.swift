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
    let configuration: CurNextWidgetConfigurationAppIntent
}

struct CurNextWidgetView : View {
    var entry: CurNextWidgetEntry

    var body: some View {
        if !entry.configuration.showCurrent && !entry.configuration.showNext {
            Text("Выберите в настройках виджета, что показывать")
                .font(.caption)
                .fontWeight(.light)
                .opacity(0.5)
        } else if entry.currentLesson == nil && entry.nextLesson == nil {
            Text("Занятий нет")
                .fontWeight(.bold)
        } else {
            VStack(alignment: .leading, spacing: 0) {
                if entry.configuration.showCurrent, let curLesson = entry.currentLesson {
                    LessonRowView(title: "Сейчас", lesson: curLesson)
                }

                if entry.configuration.showNext, let nextLesson = entry.nextLesson {
                    LessonRowView(title: "Далее", lesson: nextLesson)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
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
        .description("Текущее и/или следующее занятия в выбранном расписании.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    CurNextWidget()
} timeline: {
    CurNextWidgetEntry(date: .now,
                       currentLesson: Lesson(timeStart: 30000, timeEnd: 32000, type: "практ.", subgroup: "2", parity: [:], name: "Программирование и конфигурирование в компьютерных сетях", teacher: "Кабанова Любовь Александровна", place: "12 корпус 414 ауд."),
                       nextLesson: Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"), configuration: CurNextWidgetConfigurationAppIntent())
    CurNextWidgetEntry(date: .now,
                       currentLesson: Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"),
                       nextLesson: Lesson(timeStart: 45000, timeEnd: 50000, type: "лекция.", subgroup: "", parity: [:], name: "Математическая логика", teacher: "Молчанов", place: "12 корпус 420"), configuration: CurNextWidgetConfigurationAppIntent())
    CurNextWidgetEntry(date: .now,
                       currentLesson: Lesson(timeStart: 45000, timeEnd: 50000, type: "лекция.", subgroup: "", parity: [:], name: "Математическая логика", teacher: "Молчанов", place: "12 корпус 420"),
                       nextLesson: nil, configuration: CurNextWidgetConfigurationAppIntent())
    CurNextWidgetEntry(date: .now,
                       currentLesson: Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"),
                       nextLesson: nil, configuration: CurNextWidgetConfigurationAppIntent())
    CurNextWidgetEntry(date: .now,
                       currentLesson: nil,
                       nextLesson: Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"), configuration: CurNextWidgetConfigurationAppIntent())
    CurNextWidgetEntry(date: .now,
                       currentLesson: nil,
                       nextLesson: Lesson(timeStart: 45000, timeEnd: 50000, type: "лекция.", subgroup: "", parity: [:], name: "Математическая логика", teacher: "Молчанов", place: "12 корпус 420"), configuration: CurNextWidgetConfigurationAppIntent())
    CurNextWidgetEntry(date: .now,
                       currentLesson: nil,
                       nextLesson: nil, configuration: CurNextWidgetConfigurationAppIntent())
}
