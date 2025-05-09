//
//  GroupSchedModel.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 09.05.2025.
//

import Foundation

struct GroupSchedData: Codable {
    var university: String
    var faculty: String
    var group: String
    var date_read: String
    var schedule: [[[Lesson]]]
    var pinSchedule: [[[Bool:Int]]]
    var id: UUID
}
