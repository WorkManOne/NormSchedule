//
//  LargeListWidget.swift
//  NormWidgetExtension
//
//  Created by Кирилл Архипов on 15.04.2025.
//

import WidgetKit
import SwiftUI

struct LargeListWidgetEntry: TimelineEntry {
    var date: Date
    let lessons: [Lesson]
}

struct LargeListWidgetView : View {
    var entry: LargeListWidgetEntry

    var body: some View {
        if entry.lessons.isEmpty {
            Text("Занятий нет")
                .fontWeight(.bold)
        } else {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(entry.lessons.prefix(6)) { lesson in
                    LessonRowView(lesson: lesson)
                        //.padding(.vertical, 4)
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }
}

struct LargeListWidget: Widget {
    let kind: String = "LargeListWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: LargeListWidgetProvider()
        ) { entry in
            if #available(iOS 17.0, *) {
                LargeListWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                LargeListWidgetView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Ближайшие занятия")
        .description("Список занятий во временном порядке их следования")
        .supportedFamilies([.systemLarge, .systemExtraLarge])
    }
}

#Preview(as: .systemLarge) {
    LargeListWidget()
} timeline: {
    LargeListWidgetEntry(date: .now,
                         lessons: [
                            Lesson(timeStart: 30000, timeEnd: 32000, type: "практ.", subgroup: "2", parity: [:], name: "Программирование и конфигурирование в компьютерных сетях", teacher: "Кабанова Любовь Александровна", place: "12 корпус 414 ауд."),
                            Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"),
                            Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"),
                            Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"),
                            Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"),
                            Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"),
                            Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"),
                            Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"),
                            Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310")])
}
