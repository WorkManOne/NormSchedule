//
//  UniversityParserProtocol.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 28.04.2025.
//

import Foundation

protocol UniversityParser {
    func getFaculties() async -> Result<[FacultyModel], ParserError>
    func getGroups(uri: String) async -> Result<[GroupModel], ParserError>
    func getSchedule(uri: String) async -> Result<GroupSched, ParserError>
    func getTeachers() async -> Result<[TeacherModel], ParserError>
}
