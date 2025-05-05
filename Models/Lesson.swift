//
//  LessonModel.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 21.01.2025.
//

import Foundation
import SwiftUI

struct Lesson : Identifiable, Hashable {
    var id = UUID()
    
    var timeStart : TimeInterval //Date, Double?
    var timeEnd : TimeInterval //Date, Double?
    var type : String
    var subgroup : String
    var parity : [Bool:String]
    var name : String
    var teacher : String
    var place : String
    var importance: LessonImportance
    var note : NSAttributedString
    var isHidden : Bool
    
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.defaultDate = Calendar.current.startOfDay(for: Date())
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    static func parseTimeInterval(from timeString: String) -> TimeInterval {
        let cleaned = timeString.replacingOccurrences(of: " ", with: "")
        let parts = cleaned.components(separatedBy: ":")
        
        guard parts.count == 2,
              let hours = Int(parts[0]),
              let minutes = Int(parts[1]),
              (0...23).contains(hours),
              (0...59).contains(minutes)
        else { return 0 }
        return TimeInterval(hours * 3600 + minutes * 60)
    }
    
    init(
        id: UUID = UUID(),
        timeStart: TimeInterval, //Date,
        timeEnd: TimeInterval, //Date,
        type: String = "",
        subgroup: String = "",
        parity: [Bool: String] = [:],
        name: String,
        teacher: String = "",
        place: String = "",
        importance: LessonImportance = .unspecified,
        note: NSAttributedString = NSAttributedString(string: ""),
        isHidden: Bool = false
    ) {
        self.id = id
        self.timeStart = timeStart
        self.timeEnd = timeEnd
        self.type = type
        self.subgroup = subgroup
        self.parity = parity
        self.name = name
        self.teacher = teacher
        self.place = place
        self.importance = importance
        self.note = note
        self.isHidden = isHidden
    }
    
    func timeString() -> String {
        let start = Lesson.timeFormatter.string(from: Date(timeIntervalSinceReferenceDate: timeStart))
        let end = Lesson.timeFormatter.string(from: Date(timeIntervalSinceReferenceDate: timeEnd))
        return "\(start) - \(end)"
    }
    
    func timeStartString() -> String {
        let start = Lesson.timeFormatter.string(from: Date(timeIntervalSinceReferenceDate: timeStart))
        return "\(start)"
    }
    
    func timeEndString() -> String {
        let end = Lesson.timeFormatter.string(from: Date(timeIntervalSinceReferenceDate: timeEnd))
        return "\(end)"
    }
    
    
    //    func isCurrent(now: Date = Date()) -> Bool {
    //        return now >= timeStart && now <= timeEnd
    //    }
    //
    //    func isNext(now: Date = Date()) -> Bool {
    //        return now < timeStart
    //    }
}

extension Lesson : Codable {
    enum CodingKeys: String, CodingKey {
        case timeStart, timeEnd, type, subgroup, name, teacher, place, parity, importance, note, isHidden
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let timeStartString = try container.decode(TimeInterval.self, forKey: .timeStart)
        let timeEndString = try container.decode(TimeInterval.self, forKey: .timeEnd)
        
        //        let dateFormatter = DateFormatter()
        //        dateFormatter.dateFormat = "HH:mm"
        //
        //        guard let startDate = dateFormatter.date(from: timeStartString),
        //              let endDate = dateFormatter.date(from: timeEndString) else {
        //            throw DecodingError.dataCorruptedError(forKey: .timeStart, in: container, debugDescription: "Invalid time format")
        //        }
        
        timeStart = timeStartString //startDate
        timeEnd = timeEndString //endDate
        type = try container.decode(String.self, forKey: .type)
        subgroup = try container.decode(String.self, forKey: .subgroup)
        parity = try container.decode([Bool: String].self, forKey: .parity)
        name = try container.decode(String.self, forKey: .name)
        teacher = try container.decode(String.self, forKey: .teacher)
        place = try container.decode(String.self, forKey: .place)
        importance = try container.decode(LessonImportance.self, forKey: .importance)
        isHidden = try container.decode(Bool.self, forKey: .isHidden)
        let noteData = try container.decode(Data.self, forKey: .note)
        do {
            if let unarchivedNote = try NSKeyedUnarchiver.unarchivedObject(
                ofClass: NSAttributedString.self,
                from: noteData
            ) {
                note = unarchivedNote
            } else {
                note = NSAttributedString(string: "")
            }
        } catch {
            print("Failed to unarchive NSAttributedString")
            note = NSAttributedString(string: "")
        }
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        //        let dateFormatter = DateFormatter()
        //        dateFormatter.dateFormat = "HH:mm"
        //        let timeStartString = dateFormatter.string(from: timeStart)
        //        let timeEndString = dateFormatter.string(from: timeEnd)
        
        try container.encode(timeStart/*timeStartString*/, forKey: .timeStart)
        try container.encode(timeEnd/*timeEndString*/, forKey: .timeEnd)
        try container.encode(type, forKey: .type)
        try container.encode(subgroup, forKey: .subgroup)
        try container.encode(parity, forKey: .parity)
        try container.encode(name, forKey: .name)
        try container.encode(teacher, forKey: .teacher)
        try container.encode(place, forKey: .place)
        try container.encode(importance, forKey: .importance)
        try container.encode(isHidden, forKey: .isHidden)
        
        let noteData = try NSKeyedArchiver.archivedData(
            withRootObject: note,
            requiringSecureCoding: false
        )
        try container.encode(noteData, forKey: .note)
    }
}

extension Lesson {
    static func mock(
        id: UUID = UUID(),
        timeStart: TimeInterval = Lesson.parseTimeInterval(from: "08:30"),
        timeEnd: TimeInterval = Lesson.parseTimeInterval(from: "10:00"),
        type: String = "лекция",
        subgroup: String = "1",
        parity: [Bool: String] = [true: "Четная", false: "Нечетная"],
        name: String = "Математика",
        teacher: String = "Иванов И.И.",
        place: String = "ауд. 101",
        importance: LessonImportance = .unspecified,
        note: NSAttributedString = NSAttributedString(string: "Пара переносится"),
        isHidden: Bool = false
    ) -> Lesson {
        Lesson(
            id: id,
            timeStart: timeStart,
            timeEnd: timeEnd,
            type: type,
            subgroup: subgroup,
            parity: parity,
            name: name,
            teacher: teacher,
            place: place,
            importance: importance,
            note: note,
            isHidden: isHidden
        )
    }
}

enum LessonImportance: Int, Codable, CaseIterable, Identifiable {
    case unspecified = 0
    case low = 1
    case normal = 2
    case high = 3

    var id: Int { rawValue }

    var icon: Image? {
        switch self {
        case .unspecified:
            return nil
        case .low:
            return Image(systemName: "minus.circle")
        case .normal:
            return Image(systemName: "circle.fill")
        case .high:
            return Image(systemName: "exclamationmark.circle.fill")
        }
    }

    var iconColor: Color {
        switch self {
        case .unspecified:
            return .clear
        case .low:
            return .gray
        case .normal:
            return .blue
        case .high:
            return .red
        }
    }

    var description: String {
        switch self {
        case .unspecified: return "Важность не указана"
        case .low: return "Можно не ходить"
        case .normal: return "Желательно присутствовать"
        case .high: return "Обязательно к посещению"
        }
    }
}
