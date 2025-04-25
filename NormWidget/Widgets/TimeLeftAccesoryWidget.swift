//
//  TimeLeftAccesoryWidget.swift
//  NormWidgetExtension
//
//  Created by Кирилл Архипов on 19.04.2025.
//

import WidgetKit
import SwiftUI

struct TimeLeftAccessoryWidgetEntry: TimelineEntry {
    var date: Date
    let progress: Double
    let timeLeft: String
    let isLesson: Bool
}

struct TimeLeftAccessoryWidgetView: View {
    var entry: TimeLeftAccessoryWidgetEntry

    var body: some View {
        Gauge(value: entry.progress) {} currentValueLabel: {
            VStack {
                Text(entry.timeLeft)
                Image(systemName: entry.isLesson ? "book.fill" : "hourglass")
                    .font(.system(size: 10))
            }
        }
        .gaugeStyle(.accessoryCircularCapacity)
    }
}

struct TimeLeftAccessoryWidget: Widget {
    let kind: String = "TimeLeftAccessoryWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: TimeLeftAccessoryWidgetProvider()
        ) { entry in
            if #available(iOS 17.0, *) {
                TimeLeftAccessoryWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                TimeLeftAccessoryWidgetView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Время до конца или начала занятия")
        .description("Показывает оставшееся время до конца текущего занятия или до начала следующего.")
        .supportedFamilies([
            .accessoryCircular,
        ])
    }
}

#Preview(as: .accessoryInline) {
    TimeLeftAccessoryWidget()
} timeline: {
    TimeLeftAccessoryWidgetEntry(date: .now, progress: 0.0, timeLeft: "--:--", isLesson: true)
    TimeLeftAccessoryWidgetEntry(date: .now, progress: 0.1, timeLeft: "0:14", isLesson: true)
    TimeLeftAccessoryWidgetEntry(date: .now, progress: 0.2, timeLeft: "0:14", isLesson: true)
    TimeLeftAccessoryWidgetEntry(date: .now, progress: 0.4, timeLeft: "0:14", isLesson: true)
    TimeLeftAccessoryWidgetEntry(date: .now, progress: 0.6, timeLeft: "0:14", isLesson: true)
    TimeLeftAccessoryWidgetEntry(date: .now, progress: 0.8, timeLeft: "0:14", isLesson: true)
    TimeLeftAccessoryWidgetEntry(date: .now, progress: 1, timeLeft: "0:14", isLesson: true)
    TimeLeftAccessoryWidgetEntry(date: .now, progress: 1, timeLeft: "0:14", isLesson: false)
}
