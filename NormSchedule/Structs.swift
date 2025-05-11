//
//  Structs.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 15.04.2024.
//

import Foundation

struct UniversityModel: Identifiable, Equatable {
    var id : String
    var name : String
}

struct FacultyModel: Identifiable, Equatable {
    var id : String { uri }
    var name : String
    var uri : String
}

struct GroupModel: Identifiable, Equatable {
    var id : String { uri }
    var name : String
    var uri : String
}

struct TeacherModel: Codable, Identifiable, Equatable {
    var id : String { uri }
    var name : String
    var uri : String
    
    enum CodingKeys: String, CodingKey {
        case name = "fio"
        case uri = "id"
    }
    
    init(name: String, uri: String) {
        self.name = name
        self.uri = uri
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        
        let rawURI = try container.decode(String.self, forKey: .uri)
        if let leftDrop = rawURI.range(of: "id") {
            uri = "/schedule/teacher/\(rawURI[leftDrop.upperBound...])"
        } else {
            uri = rawURI
        }
    }
}
