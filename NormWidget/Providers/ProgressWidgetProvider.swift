//
//  ProgressWidgetProvider.swift
//  NormWidgetExtension
//
//  Created by Кирилл Архипов on 19.04.2025.
//

import Foundation
import WidgetKit

struct ProgressAccessoryWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> ProgressAccessoryWidgetEntry {
        ProgressAccessoryWidgetEntry(date: .now, progress: 0.7,
                                     lessonName: "Пример тяжелейшей пары в моем университете",
                                     timeStart: "08:20", timeEnd: "09:55")
    }

    func getSnapshot(in context: Context, completion: @escaping (ProgressAccessoryWidgetEntry) -> ()) {
        let entry =
        ProgressAccessoryWidgetEntry(date: .now, progress: 0.7,
                                     lessonName: "Пример тяжелейшей пары в моем университете",
                                     timeStart: "08:20", timeEnd: "09:55")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [ProgressAccessoryWidgetEntry] = []
        let dataManager = WidgetDataManager()
        print("getTimeline")

        let currentDate = Date()
        for minuteOffset in 0..<60 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            if let curNextInfo = dataManager.curNextInfo(date: entryDate) {
                let entry = ProgressAccessoryWidgetEntry(date: entryDate,
                                                         progress: curNextInfo.progress,
                                                         lessonName: curNextInfo.name,
                                                         timeStart: curNextInfo.timeStart,
                                                         timeEnd: curNextInfo.timeEnd)
                entries.append(entry)
            } else {
                let entry = ProgressAccessoryWidgetEntry(date: entryDate,
                                                         progress: 0, lessonName: "Пары нет", timeStart: "--:--", timeEnd: "--:--")
                entries.append(entry)
            }
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}
