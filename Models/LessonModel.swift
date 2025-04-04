//
//  LessonModel.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 21.01.2025.
//

import Foundation

struct Lesson : Identifiable, Hashable {
    var id = UUID()

    var timeStart : TimeInterval //Date
    var timeEnd : TimeInterval //Date
    var type : String
    var subgroup : String
    var parity : [Bool:String]
    var name : String
    var teacher : String
    var place : String
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
        type: String,
        subgroup: String,
        parity: [Bool: String],
        name: String,
        teacher: String,
        place: String,
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
        self.note = note
        self.isHidden = isHidden
    }

    func timeString() -> String {
        let start = Lesson.timeFormatter.string(from: Date(timeIntervalSinceReferenceDate: timeStart))
        let end = Lesson.timeFormatter.string(from: Date(timeIntervalSinceReferenceDate: timeEnd))
        return "\(start) - \(end)"
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
        case timeStart, timeEnd, type, subgroup, name, teacher, place, parity, note, isHidden
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
        try container.encode(isHidden, forKey: .isHidden)

        let noteData = try NSKeyedArchiver.archivedData(
            withRootObject: note,
            requiringSecureCoding: false
        )
        try container.encode(noteData, forKey: .note)
    }
}
