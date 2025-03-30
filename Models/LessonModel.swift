//
//  LessonModel.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 21.01.2025.
//

import Foundation

struct Lesson : Identifiable, Codable, Hashable {
    var id = UUID()

    enum CodingKeys: String, CodingKey {
        case timeStart, timeEnd, type, subgroup, name, teacher, place, parity
    }

    var timeStart : String
    var timeEnd : String
    var type : String
    var subgroup : String
    var parity : [Bool:String]
    var name : String
    var teacher : String
    var place : String
}
