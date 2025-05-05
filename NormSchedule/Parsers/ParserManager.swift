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
