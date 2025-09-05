//
//  SchedModel.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 14.03.2024.
//

import Foundation
import SwiftData
#if os(iOS)
@Model
#endif

final class GroupSched : ObservableObject {
    init(university: String, faculty: String, group: String, date_read: String, schedule: [[[Lesson]]], pinSchedule: [[[Bool:UUID]]], id: UUID? = nil) {
        self.university = university
        self.faculty = faculty
        self.group = group
        self.id = id ?? UUID()
        self.schedule = schedule
        self.pinSchedule = pinSchedule
        self.date_read = date_read
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.university = (try? container.decode(String.self, forKey: .university)) ?? "Неизвестный университет"
        self.faculty = (try? container.decode(String.self, forKey: .faculty)) ?? ""
        self.group = (try? container.decode(String.self, forKey: .group)) ?? "Название группы не указано"
        self.id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID()
        self.date_read = (try? container.decode(String.self, forKey: .date_read)) ?? ""

        do {
            self.schedule = try container.decode([[[Lesson]]].self, forKey: .schedule)
        } catch {
            self.schedule = []
        }

        do {
            self.pinSchedule = try container.decode([[[Bool:UUID]]].self, forKey: .pinSchedule)
        } catch {
            self.pinSchedule = []
        }
    }

    var university : String
    var faculty : String
    var group : String
    var date_read : String
    var schedule : [[[Lesson]]]
    var pinSchedule : [[[Bool:UUID]]]
    var id : UUID
    

    func pinnedReform() {
        guard !schedule.isEmpty, !pinSchedule.isEmpty else { return }

        for day in 0..<schedule.count {
            reformPinningsForDay(day)
        }
    }

    private func reformPinningsForDay(_ dayIndex: Int) {
        guard dayIndex < schedule.count, dayIndex < pinSchedule.count else { return }

        for lessonGroupIndex in 0..<schedule[dayIndex].count {
            guard lessonGroupIndex < pinSchedule[dayIndex].count else { continue }

            var needReformTrue = true
            var needReformFalse = true
            let pinned = pinSchedule[dayIndex][lessonGroupIndex]

            if let pinnedTrueUUID = pinned[true],
               let pinnedLesson = schedule[dayIndex][lessonGroupIndex].first(where: { $0.id == pinnedTrueUUID }),
               pinnedLesson.parity.keys.contains(true) {
                needReformTrue = false
            }

            if let pinnedFalseUUID = pinned[false],
               let pinnedLesson = schedule[dayIndex][lessonGroupIndex].first(where: { $0.id == pinnedFalseUUID }),
               pinnedLesson.parity.keys.contains(false) {
                needReformFalse = false
            }

            if needReformTrue || needReformFalse {
                for lesson in schedule[dayIndex][lessonGroupIndex] {
                    if needReformTrue && lesson.parity.keys.contains(true) {
                        pinSchedule[dayIndex][lessonGroupIndex][true] = lesson.id
                        needReformTrue = false
                    }
                    if needReformFalse && lesson.parity.keys.contains(false) {
                        pinSchedule[dayIndex][lessonGroupIndex][false] = lesson.id
                        needReformFalse = false
                    }
                    if !needReformTrue && !needReformFalse { break }
                }

                if needReformTrue {
                    pinSchedule[dayIndex][lessonGroupIndex][true] = nil
                }
                if needReformFalse {
                    pinSchedule[dayIndex][lessonGroupIndex][false] = nil
                }
            }
        }
    }

    func findLessonIndices(for lessonId: UUID) -> (dayIndex: Int, lessonGroupIndex: Int)? {
        for dayIndex in schedule.indices {
            for lessonGroupIndex in schedule[dayIndex].indices {
                if schedule[dayIndex][lessonGroupIndex].contains(where: { $0.id == lessonId }) {
                    return (dayIndex: dayIndex, lessonGroupIndex: lessonGroupIndex)
                }
            }
        }
        return nil
    }

    func repositionLessonById(_ lesson: Lesson) {
        guard let indices = findLessonIndices(for: lesson.id) else {
            print("Lesson with ID \(lesson.id) not found")
            return
        }

        repositionLesson(lesson, inDay: indices.dayIndex, fromLessonGroup: indices.lessonGroupIndex)
    }

    func repositionLesson(_ lesson: Lesson, inDay dayIndex: Int, fromLessonGroup originalLessonGroupIndex: Int) {
        guard dayIndex < schedule.count else { return }

        removeLessonFromOriginalPosition(lesson, dayIndex: dayIndex, lessonGroupIndex: originalLessonGroupIndex)
        let targetIndex = findCorrectPosition(for: lesson, inDay: dayIndex)
        insertLessonAtPosition(lesson, dayIndex: dayIndex, targetIndex: targetIndex)
        reformPinningsForDay(dayIndex)
    }

    private func removeLessonFromOriginalPosition(_ lesson: Lesson, dayIndex: Int, lessonGroupIndex: Int) {
        guard lessonGroupIndex < schedule[dayIndex].count else { return }

        // Удаляем пару из массива
        schedule[dayIndex][lessonGroupIndex].removeAll { $0.id == lesson.id }

        // Если массив стал пустым, удаляем его и соответствующий элемент из pinSchedule
        if schedule[dayIndex][lessonGroupIndex].isEmpty {
            schedule[dayIndex].remove(at: lessonGroupIndex)

            // Обеспечиваем соответствие размеров массивов
            if lessonGroupIndex < pinSchedule[dayIndex].count {
                pinSchedule[dayIndex].remove(at: lessonGroupIndex)
            }
        }
    }

    private func findCorrectPosition(for lesson: Lesson, inDay dayIndex: Int) -> Int {
        let daySchedule = schedule[dayIndex]

        for (index, lessonGroup) in daySchedule.enumerated() {
            guard let firstLessonInGroup = lessonGroup.first else { continue }

            // Сравниваем времена по приоритету: начало -> конец
            if lesson.timeStart < firstLessonInGroup.timeStart {
                return index
            } else if lesson.timeStart == firstLessonInGroup.timeStart {
                if lesson.timeEnd <= firstLessonInGroup.timeEnd {
                    return index
                }
            }
        }

        // Если не нашли подходящую позицию, добавляем в конец
        return daySchedule.count
    }

    private func insertLessonAtPosition(_ lesson: Lesson, dayIndex: Int, targetIndex: Int) {
        // Проверяем, есть ли уже группа с таким же временем
        if targetIndex < schedule[dayIndex].count {
            let existingGroup = schedule[dayIndex][targetIndex]
            if let firstLesson = existingGroup.first,
               firstLesson.timeStart == lesson.timeStart && firstLesson.timeEnd == lesson.timeEnd {
                // Добавляем в существующую группу
                schedule[dayIndex][targetIndex].append(lesson)
                return
            }
        }

        // Создаем новую группу
        schedule[dayIndex].insert([lesson], at: targetIndex)

        // Обеспечиваем соответствие в pinSchedule
        while pinSchedule[dayIndex].count <= targetIndex {
            pinSchedule[dayIndex].append([:])
        }

        if targetIndex < pinSchedule[dayIndex].count {
            pinSchedule[dayIndex].insert([:], at: targetIndex)
        }
    }
}


extension GroupSched: Codable {
    private enum CodingKeys: String, CodingKey {
        case university, faculty, group, date_read, schedule, pinSchedule, id
    }

    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(university, forKey: .university)
        try values.encode(faculty, forKey: .faculty)
        try values.encode(group, forKey: .group)
        try values.encode(id, forKey: .id)
        try values.encode(schedule, forKey: .schedule)
        try values.encode(pinSchedule, forKey: .pinSchedule)
        try values.encode(date_read, forKey: .date_read)
    }

    func asData() -> GroupSchedData {
        GroupSchedData(
            university: university,
            faculty: faculty,
            group: group,
            date_read: date_read,
            schedule: schedule,
            pinSchedule: pinSchedule,
            id: id
        )
    }
}
