//
//  ParserMain.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 15.04.2024.
//

import Foundation
import SwiftSoup

//@MainActor //TODO: Решение потокобезопасности SwiftData??
//class Parser {
//    static let shared = Parser()
//}

final class ParserManager {
    static func parser(for universityID: String) -> UniversityParser? {
        switch universityID {
        case "1":
            return SSUParser()
        case "2":
            return SSTUParser()
        default:
            return nil
        }
    }
}

//func getGroup(id: Int, uri: String, completion: @escaping (GroupSched) -> Void) {
//    let scheduleOfGroup = GroupSched(university: "",
//                                     faculty: "",
//                                     group: "",
//                                     date_read: "",
//                                     schedule: [],
//                                     pinSchedule: [])
//    switch id {
//    case 1:
//        SSU_getSchedule (uri: uri) { s in
//            s.pinnedReform() //TODO: FiX logic
//            completion(s)
//        }
//    case 2:
//        SSTU_getSchedule (uri: uri) { s in
//            s.pinnedReform() //TODO: FiX logic
//            completion(s)
//        }
//    default:
//        completion(scheduleOfGroup)
//    }
//    
//}

