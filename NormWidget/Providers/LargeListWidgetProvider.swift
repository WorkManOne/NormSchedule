//
//  LargeListWidgetProvider.swift
//  NormWidgetExtension
//
//  Created by Кирилл Архипов on 16.04.2025.
//

import Foundation
import WidgetKit
import AppIntents

struct LargeListWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> LargeListWidgetEntry {
        LargeListWidgetEntry(date: .now,
                             lessons: [DataManager.LessonWithTitle(lesson: Lesson(timeStart: 30000, timeEnd: 32000, type: "практ.", subgroup: "2", parity: [:], name: "Программирование и конфигурирование в компьютерных сетях", teacher: "Кабанова Любовь Александровна", place: "12 корпус 414 ауд."), title: "Cейчас"),
                                       DataManager.LessonWithTitle(lesson: Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"), title: "Далее"),
                                       DataManager.LessonWithTitle(lesson: Lesson(timeStart: 42000, timeEnd: 45000, type: "лекция.", subgroup: "", parity: [:], name: "Компьютерные сети", teacher: "Мистер Лектор", place: "Аудитория 215"), title: nil),
                                       DataManager.LessonWithTitle(lesson: Lesson(timeStart: 46000, timeEnd: 50000, type: "лекция.", subgroup: "", parity: [:], name: "Пример пары", teacher: "Пример преподавателя", place: "12 к. 310"), title: nil),
                                       DataManager.LessonWithTitle(lesson: Lesson(timeStart: 30000, timeEnd: 32000, type: "практика.", subgroup: "подгр. 1", parity: [true:"чет."], name: "Статистический анализ данных", teacher: "Иванов Иван Иванович", place: "10 к. 418 ауд."), title: "Завтра"),
                                       DataManager.LessonWithTitle(lesson: Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"), title: "Понедельник"),
                                       DataManager.LessonWithTitle(lesson: Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"), title: "Вторник")])
    }

    func getSnapshot(in context: Context, completion: @escaping (LargeListWidgetEntry) -> ()) {
        let entry =
        LargeListWidgetEntry(date: .now,
                             lessons: [DataManager.LessonWithTitle(lesson: Lesson(timeStart: 30000, timeEnd: 32000, type: "практ.", subgroup: "2", parity: [:], name: "Программирование и конфигурирование в компьютерных сетях", teacher: "Кабанова Любовь Александровна", place: "12 корпус 414 ауд."), title: "Cейчас"),
                                       DataManager.LessonWithTitle(lesson: Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"), title: "Далее"),
                                       DataManager.LessonWithTitle(lesson: Lesson(timeStart: 42000, timeEnd: 45000, type: "лекция.", subgroup: "", parity: [:], name: "Компьютерные сети", teacher: "Мистер Лектор", place: "Аудитория 215"), title: nil),
                                       DataManager.LessonWithTitle(lesson: Lesson(timeStart: 46000, timeEnd: 50000, type: "лекция.", subgroup: "", parity: [:], name: "Пример пары", teacher: "Пример преподавателя", place: "12 к. 310"), title: nil),
                                       DataManager.LessonWithTitle(lesson: Lesson(timeStart: 30000, timeEnd: 32000, type: "практика.", subgroup: "подгр. 1", parity: [true:"чет."], name: "Статистический анализ данных", teacher: "Иванов Иван Иванович", place: "10 к. 418 ауд."), title: "Завтра"),
                                       DataManager.LessonWithTitle(lesson: Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"), title: "Понедельник"),
                                       DataManager.LessonWithTitle(lesson: Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"), title: "Вторник")])
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [LargeListWidgetEntry] = []
        let dataManager = DataManager()
        let currentDate = Date()
        print("getTimeline")

        var nextEntryDate: Date =  Date()
        for _ in 0..<5 {
            let entryDate = nextEntryDate
            let lessons = dataManager.upcomingLessons(date: entryDate, count: 6)
            let entry = LargeListWidgetEntry(date: entryDate, lessons: lessons)
            entries.append(entry)

            let midnight = Calendar.current.startOfDay(for: entryDate)
            let currentTime = entryDate.timeIntervalSince(midnight)

            if let first = lessons.first, currentTime >= first.lesson.timeStart && currentTime < first.lesson.timeEnd {
                nextEntryDate = midnight.addingTimeInterval(first.lesson.timeEnd)
            } else if let first = lessons.first, first.lesson.timeStart > currentTime {
                nextEntryDate = midnight.addingTimeInterval(first.lesson.timeStart)
            } else {
                nextEntryDate = entryDate.addingTimeInterval(3600)
            }
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}
