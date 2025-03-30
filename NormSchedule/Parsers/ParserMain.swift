//
//  ParserMain.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 15.04.2024.
//

import Foundation
import SwiftSoup

func getFacultiesUri(id: Int, completion: @escaping ([Faculty]) -> Void) {
    switch id {
    case 1:
        SSU_getFacultiesUri { f in
            completion(f)
        }
        break
    case 2:
        SSTU_getFacultiesUri { f in
            completion(f)
        }
        break
    default:
        completion([])
    }

}

func getGroupsUri(id: Int, uri : String, completion: @escaping ([Group]) -> Void) {
    switch id {
    case 1:
        SSU_getGroupsUri (uri: uri) { g in
            completion(g)
        }
    case 2:
        SSTU_getGroupsUri (uri: uri) { g in
            completion(g)
        }
    default:
        completion([])
    }
    
}

func getGroup(id: Int, uri: String, completion: @escaping (GroupSched) -> Void) {
    let scheduleOfGroup = GroupSched(university: "",
                                     faculty: "",
                                     group: "",
                                     date_read: "",
                                     schedule: [],
                                     pinSchedule: [])
    switch id {
    case 1:
        SSU_getSchedule (uri: uri) { s in
            s.pinnedReform() //TODO: FiX logic
            completion(s)
        }
    case 2:
        SSTU_getSchedule (uri: uri) { s in
            s.pinnedReform()
            completion(s)
        }
    default:
        completion(scheduleOfGroup)
    }
    
}

func getTeachersUri(id: Int, completion: @escaping ([Teacher]) -> Void) {
    switch id {
    case 1:
        SSU_getTeachersUri { t in
            completion(t)
        }
    case 2:
        SSTU_getTeachersUri  { t in
            completion(t)
        }
    default:
        completion([])
    }
}
