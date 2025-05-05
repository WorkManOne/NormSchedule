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
                           currentLesson: Lesson(timeStart: 30000, timeEnd: 32000, type: "практ.", subgroup: "Подгр. 2", parity: [:], name: "Практическая пара с практическими знаниями", teacher: "Фамилия Имя Отчество", place: "Место встречи изменить нельзя"),
                           nextLesson: Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"), nextTitle: "Далее",
                           configuration: CurNextWidgetConfigurationAppIntent())
    }

    func snapshot(for configuration: Intent, in context: Context) async -> Entry {
        let entry =
        CurNextWidgetEntry(date: .now,
                           currentLesson: Lesson(timeStart: 30000, timeEnd: 32000, type: "практ.", subgroup: "Подгр. 2", parity: [:], name: "Практическая пара с практическими знаниями", teacher: "Фамилия Имя Отчество", place: "Место встречи изменить нельзя"),
                           nextLesson: Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"), nextTitle: "Далее",
                           configuration: configuration)
        return entry
    }

    func timeline(for configuration: Intent, in context: Context) async -> Timeline<Entry> {
        var entries: [CurNextWidgetEntry] = []
        let dataManager = WidgetDataManager()
        print("getTimeline")

        var nextEntryDate: Date =  Date()
        for _ in 0..<5 {
            let entryDate = nextEntryDate
            let current = dataManager.currentLesson(date: entryDate)
            let next = dataManager.nextLesson(date: entryDate)
            let nextTitle: String? = {
                guard let nextDate = next?.date else { return nil }
                let calendar = Calendar.current
                let startOfToday = calendar.startOfDay(for: entryDate)
                let startOfNext = calendar.startOfDay(for: nextDate)
                let daysBetween = calendar.dateComponents([.day], from: startOfToday, to: startOfNext).day ?? 0

                switch daysBetween {
                case 0:
                    return "Далее"
                case 1:
                    return "Завтра"
                default:
                    let formatter = DateFormatter()
                    formatter.locale = Locale(identifier: "ru_RU")
                    formatter.dateFormat = "EE"
                    let weekday = formatter.string(from: nextDate).capitalized
                    return weekday
                }
            }()

            let entry = CurNextWidgetEntry(
                date: entryDate,
                currentLesson: current,
                nextLesson: next?.lesson,
                nextTitle: nextTitle,
                configuration: configuration
            )
            entries.append(entry)

            let midnight = Calendar.current.startOfDay(for: entryDate)
            if let current = current {
                nextEntryDate = midnight.addingTimeInterval(current.timeEnd)
            } else if let next = next {
                nextEntryDate = midnight.addingTimeInterval(next.lesson.timeStart)
            } else {
                nextEntryDate = entryDate.addingTimeInterval(3600)
            }
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        return timeline
    }

    //    func relevances() async -> WidgetRelevances<Void> {
    //        // Generate a list containing the contexts this widget is relevant in.
    //    }
}
