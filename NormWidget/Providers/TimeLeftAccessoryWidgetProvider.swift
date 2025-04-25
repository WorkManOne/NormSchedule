//
//  TimeLeftAccessoryWidgetProvider.swift
//  NormWidgetExtension
//
//  Created by Кирилл Архипов on 19.04.2025.
//

import Foundation
import WidgetKit

struct TimeLeftAccessoryWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> TimeLeftAccessoryWidgetEntry {
        TimeLeftAccessoryWidgetEntry(date: .now, progress: 0.7, timeLeft: "00:57", isLesson: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (TimeLeftAccessoryWidgetEntry) -> ()) {
        let entry =
        TimeLeftAccessoryWidgetEntry(date: .now, progress: 0.7, timeLeft: "00:57", isLesson: true)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [TimeLeftAccessoryWidgetEntry] = []
        let dataManager = DataManager()
        print("getTimeline")

        let currentDate = Date()
        for minuteOffset in 0..<60 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            if let curNextInfo = dataManager.curNextInfo(date: entryDate) {
                let entry = TimeLeftAccessoryWidgetEntry(date: entryDate, progress: 1 - curNextInfo.progress, timeLeft: curNextInfo.timeLeft, isLesson: curNextInfo.isLesson)
                entries.append(entry)
            } else {
                let entry = TimeLeftAccessoryWidgetEntry(date: entryDate, progress: 0, timeLeft: "--:--", isLesson: false)
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
