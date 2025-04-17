//
//  AccessoryWidgets.swift
//  NormWidgetExtension
//
//  Created by Кирилл Архипов on 15.04.2025.
//

import WidgetKit
import SwiftUI
import AppIntents

//struct CurNextWidgetEntry: TimelineEntry {
//    var date: Date
//    let currentLesson: Lesson?
//    let nextLesson: Lesson?
//    let configuration: CurNextWidgetConfigurationAppIntent
//}

struct NextAccessoryWidgetView: View {
    @Environment(\.widgetFamily) var family
    var entry: CurNextWidgetEntry

    var body: some View {
        switch family {
        case .accessoryInline:
            Text("До конца пары: 14 минут")
        case .accessoryCircular:
            Gauge(value: 0.2) {} currentValueLabel: {
                VStack {
                    Text("0:19")
                    Image(systemName: "book.fill")
                        .font(.system(size: 10))
                }
            }
            .gaugeStyle(.accessoryCircularCapacity)
        case .accessoryRectangular:
            VStack(alignment: .leading) {
                if entry.configuration.showCurrent, let curLesson = entry.currentLesson {
                    HStack {
                        Text("| \(curLesson.name)")
                            .font(.caption2)
                    }
                }
                if entry.configuration.showNext, let nextLesson = entry.nextLesson {
                    HStack {
                        Text("| \(nextLesson.name)")
                            .font(.caption2)
                    }
                }
            }
        default:
            Text("Не поддерживается")
        }
    }
}

struct NextAccessoryWidget: Widget {
    let kind: String = "AccessoryWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: CurNextWidgetConfigurationAppIntent.self,
            provider: CurNextWidgetProvider()
        ) { entry in
            if #available(iOS 17.0, *) {
                NextAccessoryWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                NextAccessoryWidgetView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Мой виджет")
        .description("Виджет для Dynamic Island и часов")
        .supportedFamilies([
            .accessoryInline,
            .accessoryCircular,
            .accessoryRectangular
        ])
    }
}

#Preview(as: .accessoryInline) {
    NextAccessoryWidget()
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
