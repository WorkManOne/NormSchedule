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
    init(university: String, faculty: String, group: String, date_read: String, schedule: [[[Lesson]]], pinSchedule: [[[Bool:Int]]], id: UUID? = nil) {
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
            self.pinSchedule = try container.decode([[[Bool:Int]]].self, forKey: .pinSchedule)
        } catch {
            self.pinSchedule = []
        }
    }

    var university : String
    var faculty : String
    var group : String
    var date_read : String
    var schedule : [[[Lesson]]]
    var pinSchedule : [[[Bool:Int]]]
    var id : UUID


    func pinnedReform() {
        guard !schedule.isEmpty, !pinSchedule.isEmpty else { return }

        for day in 0..<schedule.count {

            guard pinSchedule.indices.contains(day) else { continue }

            for lessons in 0..<schedule[day].count {
                guard pinSchedule[day].indices.contains(lessons) else { continue }

                var needReformTrue = true
                var needReformFalse = true
                let pinned = pinSchedule[day][lessons]

                let pinnedTrueIndex = pinned[true] ?? 0
                let pinnedFalseIndex = pinned[false] ?? 0

                if schedule[day][lessons].indices.contains(pinnedTrueIndex),
                   schedule[day][lessons][pinnedTrueIndex].parity.keys.contains(true) {
                    needReformTrue = false
                }
                if schedule[day][lessons].indices.contains(pinnedFalseIndex),
                   schedule[day][lessons][pinnedFalseIndex].parity.keys.contains(false) {
                    needReformFalse = false
                }

                if needReformTrue || needReformFalse {
                    for lesson in 0..<schedule[day][lessons].count {
                        if needReformTrue && schedule[day][lessons][lesson].parity.keys.contains(true) {
                            pinSchedule[day][lessons][true] = lesson
                            needReformTrue = false
                        }
                        if needReformFalse && schedule[day][lessons][lesson].parity.keys.contains(false) {
                            pinSchedule[day][lessons][false] = lesson
                            needReformFalse = false
                        }
                        if !needReformTrue && !needReformFalse { break }
                    }
                }
            }
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
