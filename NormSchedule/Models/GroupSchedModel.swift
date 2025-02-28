//
//  SchedModel.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 14.03.2024.
//

import Foundation
import SwiftData

@Model
class GroupSched : ObservableObject {
    init(university: String, faculty: String, group: String, date_read: String, schedule: [[[Lesson]]], pinSchedule: [[[Bool:Int]]], id: UUID? = nil) {
        self.university = university
        self.faculty = faculty
        self.group = group
        self.id = UUID(uuidString: "\(university)\(faculty)\(group)") ?? UUID()
        self.schedule = schedule
        self.pinSchedule = pinSchedule
        self.date_read = date_read
    }
    
    var university : String
    var faculty : String
    var group : String
    var date_read : String
    var schedule : [[[Lesson]]]
    var pinSchedule : [[[Bool:Int]]]
    var id : UUID


    func pinnedReform() {
        let settingsManager = SettingsManager()
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

        print("reformed: now - \(settingsManager.isEvenWeek)")
    }

//    func pinnedReform() {
//        let settingsManager = SettingsManager()
//        //Добавить реформ всех расписаний?? Или сделать так чтобы они реформились когда их загружаешь
//        for day in 0..<schedule.count { //А если дня не будет? - Так тогда и цикла не будет ебана мяу (или он будет ограничен тем количеством дней которые есть)
//            for lessons in 0..<schedule[day].count {
//                var needReformTrue = true
//                var needReformFalse = true
//                let pinned = pinSchedule[day][lessons]
//                //print(items[currItem].schedule[day][lessons], pinned[true] ?? 0)
//                if schedule[day][lessons].isEmpty { return }
//                if (schedule[day][lessons][pinned[true] ?? 0].parity.keys.contains(true)) {
//                    needReformTrue = false
//                }
//                if (schedule[day][lessons][pinned[false] ?? 0].parity.keys.contains(false)) {
//                    needReformFalse = false
//                }
//                
//                if (needReformTrue || needReformFalse) {
//                    for lesson in 0..<schedule[day][lessons].count {
//                        if (needReformTrue && schedule[day][lessons][lesson].parity.keys.contains(true)) {
//                            pinSchedule[day][lessons][true] = lesson
//                                needReformTrue = false
//                        }
//                        if (needReformFalse && schedule[day][lessons][lesson].parity.keys.contains(false)) {
//                            pinSchedule[day][lessons][false] = lesson
//                            needReformFalse = false
//                        }
//                        if (!needReformTrue && !needReformFalse) { break }
//                    }
//                }
//            }
//        }
//        print("reformed: now - \(settingsManager.isEvenWeek)")
//        
//    }
}




//    private enum CodingKeys: String, CodingKey {
//            case university, faculty, group, date_read, schedule, pinSchedule, id
//    }
    
//    required init(from decoder:Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        university = try values.decode(String.self, forKey: .university)
//        try values.decode(String.self, forKey: .faculty)
//        try values.decode(String.self, forKey: .group)
//        try values.decode(UUID.self, forKey: .id)
//        try values.decode([[[Lesson]]].self, forKey: .schedule)
//        try values.decode([[[Bool:Int]]].self, forKey: .pinSchedule)
//        try values.decode(String.self, forKey: .date_read)
//    }
//    public func encode(to encoder: Encoder) throws {
//            var values = encoder.container(keyedBy: CodingKeys.self)
//            try values.encode(university, forKey: .university)
//            try values.encode(faculty, forKey: .faculty)
//            try values.encode(group, forKey: .group)
//            try values.encode(id, forKey: .id)
//            try values.encode(schedule, forKey: .schedule)
//            try values.encode(pinSchedule, forKey: .pinSchedule)
//            try values.encode(date_read, forKey: .date_read)
//    }
//    var pinSchedule : [[Int]] =   [ [[true:0, false:0],[true:0, false:0],[true:0, false:0],[true:2, false:0],[true:0, false:0],[true:0, false:0],[true:0, false:0],[true:0, false:0],[true:0, false:0]], [1,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0] ]
