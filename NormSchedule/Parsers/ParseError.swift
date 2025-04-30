//
//  ParseError.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 28.04.2025.
//

import Foundation

enum ParserError: Error {
    case networkError
    case invalidData
    case parsingFailed(reason: String)
    case unknown
}

extension ParserError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Не удалось загрузить данные. Проверьте интернет-соединение."
        case .invalidData:
            return "Получены некорректные данные."
        case .parsingFailed(let reason):
            return "Ошибка парсинга: \(reason)"
        case .unknown:
            return "Неизвестная ошибка."
        }
    }
}
