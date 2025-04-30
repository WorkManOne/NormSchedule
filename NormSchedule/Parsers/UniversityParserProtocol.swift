//
//  UniversityParserProtocol.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 28.04.2025.
//

import Foundation

protocol UniversityParser {
    func getFaculties() async -> Result<[Faculty], ParserError>
    func getGroups(uri: String) async -> Result<[Group], ParserError>
    func getSchedule(uri: String) async -> Result<GroupSched, ParserError>
    func getTeachers() async -> Result<[Teacher], ParserError>
}
