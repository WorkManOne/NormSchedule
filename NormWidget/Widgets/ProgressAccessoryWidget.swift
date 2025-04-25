//
//  TimerAccessoryWidget.swift
//  NormWidgetExtension
//
//  Created by Кирилл Архипов on 17.04.2025.
//

import WidgetKit
import SwiftUI

struct ProgressAccessoryWidgetEntry: TimelineEntry {
    var date: Date
    let progress: Double
    let lessonName: String
    let timeStart: String
    let timeEnd: String
}

struct ProgressAccessoryWidget: Widget {
    let kind: String = "ProgressAccessoryWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: ProgressAccessoryWidgetProvider()
        ) { entry in
            if #available(iOS 17.0, *) {
                ProgressAccessoryWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                ProgressAccessoryWidgetView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Время занятия")
        .description("Начало, окончание и сколько времени уже прошло.")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular
        ])
    }
}

#Preview(as: .accessoryInline) {
    ProgressAccessoryWidget()
} timeline: {
    ProgressAccessoryWidgetEntry(date: .now, progress: 0.2, lessonName: "Программирование и конфигурирование в компьютерных сетях", timeStart: "12:30", timeEnd: "23:12")
    ProgressAccessoryWidgetEntry(date: .now, progress: 0.4, lessonName: "Программирование и конфигурирование в компьютерных сетях", timeStart: "12:30", timeEnd: "23:12")
    ProgressAccessoryWidgetEntry(date: .now, progress: 0.6, lessonName: "Программирование и конфигурирование в компьютерных сетях", timeStart: "12:30", timeEnd: "23:12")
    ProgressAccessoryWidgetEntry(date: .now, progress: 0.8, lessonName: "Программирование и конфигурирование в компьютерных сетях", timeStart: "12:30", timeEnd: "23:12")
    ProgressAccessoryWidgetEntry(date: .now, progress: 1.0, lessonName: "Пары нет", timeStart: "--:--", timeEnd: "--:--")
}
