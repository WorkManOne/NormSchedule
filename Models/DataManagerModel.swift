//
//  DataManagerModel.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 19.04.2025.
//

import Foundation
import SwiftUI
import WidgetKit

final class DataManager {
    private let userDefaults = UserDefaults(suiteName: "group.NormSchedule")

    private let scheduleKey = "schedule"
    private let parityKey = "parity"

    private(set) var schedule: GroupSched?
    private(set) var parity: Int?

    init() {
        load()
    }

    func load() {
        if let data = userDefaults?.data(forKey: scheduleKey),
           let decoded = try? JSONDecoder().decode(GroupSched.self, from: data) {
            schedule = decoded
        }
        if let parityValue = userDefaults?.value(forKey: parityKey) as? Int {
            parity = parityValue
        }
    }

    func save(schedule: GroupSched) {
        if let data = try? JSONEncoder().encode(schedule) {
            userDefaults?.set(data, forKey: scheduleKey)
        }
        self.schedule = schedule
        updateWidgets()
    }
    
    func save(parity: Int) {
        userDefaults?.set(parity, forKey: parityKey)
        self.parity = parity
        updateWidgets()
    }

    func updateWidgets() {
        WidgetCenter.shared.reloadTimelines(ofKind: "CurNextWidget")
        WidgetCenter.shared.reloadTimelines(ofKind: "TimeLeftAccessoryWidget")
        WidgetCenter.shared.reloadTimelines(ofKind: "ProgressAccessoryWidget")
        WidgetCenter.shared.reloadTimelines(ofKind: "LargeListWidget")
    }

    func lessonsForParity(parity: Int) -> [[Lesson]] {
        guard let schedule = schedule else { return [] }
        var result: [[Lesson]] = []
        for day in 0..<schedule.pinSchedule.count {
            var lessons: [Lesson] = []
            for index in 0..<schedule.pinSchedule[day].count {
                let isParityIncluded = parity == 0 || schedule.pinSchedule[day][index].keys.contains(parity != 2)
                let key = parity != 2 ? true : false
                if isParityIncluded,
                   let lessonIndex = schedule.pinSchedule[day][index][key],
                   (schedule.schedule[day][index][lessonIndex].parity.keys.contains(key) || schedule.schedule[day][index][lessonIndex].parity.isEmpty || parity == 0),
                   schedule.schedule[day][index][lessonIndex].name != "Пары нет",
                   schedule.schedule[day][index][lessonIndex].name != "Биг Чиллинг!" { //TODO: Нужно будет разрешить как то такие nil пары
                    lessons.append(schedule.schedule[day][index][lessonIndex])
                }
            }
            result.append(lessons)
        }
        return result
    }

    func computeParity(for date: Date) -> Int {
        guard let baseParity = parity, baseParity != 0
        else { return 0 }

        let calendar = Calendar.current
        let baseWeek = calendar.component(.weekOfYear, from: .now)
        let currentWeek = calendar.component(.weekOfYear, from: date)

        let weeksPassed = currentWeek - baseWeek
        let parityOffset = weeksPassed % 2

        if baseParity == 1 {
            return parityOffset == 0 ? 1 : 2
        } else {
            return parityOffset == 0 ? 2 : 1
        }
    }

    func nextLesson(date: Date) -> LessonWithDate? {
        let calendar = Calendar.current
        let midnight = calendar.startOfDay(for: date)
        let currentTime = date.timeIntervalSince(midnight)

        for dayOffset in 0..<7 {
            let searchDate = calendar.date(byAdding: .day, value: dayOffset, to: date)!
            let computedParity = computeParity(for: searchDate)
            let parityLessons = lessonsForParity(parity: computedParity)
            let weekday = (calendar.component(.weekday, from: searchDate) + 5) % 7
            guard weekday < parityLessons.count else { continue }
            let lessonsToday = parityLessons[weekday]

            for lesson in lessonsToday {
                if dayOffset == 0 {
                    if lesson.timeStart > currentTime {
                        return LessonWithDate(lesson: lesson, date: searchDate)
                    }
                } else {
                    return LessonWithDate(lesson: lesson, date: searchDate)
                }
            }
        }

        return nil
    }

    func currentLesson(date: Date) -> Lesson? {
        guard let schedule = schedule else { return nil }

        let weekday = Calendar.current.component(.weekday, from: date)
        let todayIndex = (weekday + 5) % 7

        guard todayIndex < schedule.schedule.count else { return nil }
        guard todayIndex < schedule.pinSchedule.count else { return nil }

        let calendar = Calendar.current
        let midnight = calendar.startOfDay(for: date)
        let currentTime = date.timeIntervalSince(midnight)

        let computedParity = computeParity(for: date)
        let parityLessons = lessonsForParity(parity: computedParity)
        var currentLesson : Lesson? = nil
        for lesson in parityLessons[todayIndex] {
            if currentTime >= lesson.timeStart
                && currentTime < lesson.timeEnd { //TODO: По хорошему уточнить все таки что "по времени" является текущим/следуюшим/прошлым занятием
                currentLesson = lesson
                break
            }
        }
        return currentLesson
    }

    func prevLesson(date: Date) -> LessonWithDate? {
        let calendar = Calendar.current
        let midnight = calendar.startOfDay(for: date)
        let currentTime = date.timeIntervalSince(midnight)

        for dayOffset in 0..<7 {
            let searchDate = calendar.date(byAdding: .day, value: -dayOffset, to: date)!
            let computedParity = computeParity(for: searchDate)
            let parityLessons = lessonsForParity(parity: computedParity)
            let weekday = (calendar.component(.weekday, from: searchDate) + 5) % 7
            guard weekday < parityLessons.count else { continue }
            let lessonsToday = parityLessons[weekday]

            for lesson in lessonsToday.reversed() {
                if dayOffset == 0 {
                    if lesson.timeEnd <= currentTime {
                        return LessonWithDate(lesson: lesson, date: searchDate)
                    }
                } else {
                    return LessonWithDate(lesson: lesson, date: searchDate)
                }
            }
        }

        return nil
    }

    struct ProgressWidgetModel {
        var name: String
        var progress: Double
        var timeLeft: String
        var timeStart: String
        var timeEnd: String
        var isLesson: Bool
    }

    func curNextInfo(date: Date) -> ProgressWidgetModel? {
        let calendar = Calendar.current

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(secondsFromGMT: 0) //TODO: Хуйня из за которой кажется надо все таки брать Double а не TimeInterval в Lesson

        if let current = currentLesson(date: date) {
            let midnight = calendar.startOfDay(for: date)
            let lessonStart = midnight.addingTimeInterval(current.timeStart)
            let lessonEnd = midnight.addingTimeInterval(current.timeEnd)
            let totalDuration = lessonEnd.timeIntervalSince(lessonStart)
            let elapsed = date.timeIntervalSince(lessonStart)

            let remaining = max(0, totalDuration - elapsed)
            let minutesLeft = Int(ceil(remaining / 60))
            let hourMinuteString = String(format: "%02d:%02d", minutesLeft / 60, minutesLeft % 60)
            return ProgressWidgetModel(name: current.name, progress: max(0, min(1, elapsed / totalDuration)), timeLeft: hourMinuteString, timeStart: current.timeStartString(), timeEnd: current.timeEndString(), isLesson: true)
        } else if let prev = prevLesson(date: date), let next = nextLesson(date: date) {
            let prevEnd = calendar.startOfDay(for: prev.date).addingTimeInterval(prev.lesson.timeEnd)
            let nextStart = calendar.startOfDay(for: next.date).addingTimeInterval(next.lesson.timeStart)
            let totalDuration = nextStart.timeIntervalSince(prevEnd)
            let elapsed = date.timeIntervalSince(prevEnd)
            let remaining = max(0, totalDuration - elapsed)
            let minutesLeft = Int(ceil(remaining / 60))
            let hourMinuteString = String(format: "%02d:%02d", minutesLeft / 60, minutesLeft % 60)
            return ProgressWidgetModel(name: next.lesson.name, progress: max(0, min(1, elapsed / totalDuration)), timeLeft: hourMinuteString, timeStart: prev.lesson.timeEndString(), timeEnd: next.lesson.timeStartString(), isLesson: false)
        }
        return nil
    }

    struct LessonWithDate {
        let lesson: Lesson
        let date: Date
    }

    func upcomingLessons(date: Date, count: Int) -> [LessonWithTitle] {
        var result: [LessonWithTitle] = []
        var currentDate = date
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: date)
        var lastDay: Date?

        while result.count < count {
            if result.isEmpty, let currentLesson = currentLesson(date: currentDate) {
                let midnight = calendar.startOfDay(for: currentDate)
                currentDate = midnight.addingTimeInterval(currentLesson.timeEnd + 1)
                result.append(LessonWithTitle(lesson: currentLesson, title: "Сейчас"))
                continue
            }
            guard let nextLesson = nextLesson(date: currentDate) else { break }
            let lessonDate = calendar.startOfDay(for: nextLesson.date)
            let daysDiff = calendar.dateComponents([.day], from: today, to: lessonDate).day ?? 0

            let title: String? = (lastDay != lessonDate) ? {
                switch daysDiff {
                case 0: return "Далее"
                case 1: return "Завтра"
                default:
                    let formatter = DateFormatter()
                    formatter.locale = Locale(identifier: "ru_RU")
                    formatter.dateFormat = "EEEE"
                    return formatter.string(from: lessonDate).capitalized
                }
            }() : nil

            result.append(LessonWithTitle(lesson: nextLesson.lesson, title: title))
            lastDay = lessonDate
            let midnight = calendar.startOfDay(for: nextLesson.date)
            currentDate = midnight.addingTimeInterval(nextLesson.lesson.timeEnd + 1)
        }

        return result
    }

    struct LessonWithTitle {
        let lesson: Lesson
        let title: String?
    }

}
