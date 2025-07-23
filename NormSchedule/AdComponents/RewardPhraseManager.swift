//
//  RewardPhraseManager.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 19.07.2025.
//

import Foundation
import SwiftUI

class RewardPhraseManager: ObservableObject {
    @Published var currentPhrase: String? = nil
    @Published var currentAnimation: String? = nil
    @AppStorage("usedPhrasesData") private var usedPhrasesData: Data = Data()
    @AppStorage("usedAnimationsData") private var usedAnimationsData: Data = Data()

    var usedPhrases: Set<String> {
        get {
            (try? JSONDecoder().decode(Set<String>.self, from: usedPhrasesData)) ?? []
        }
        set {
            usedPhrasesData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }
    var usedAnimations: Set<String> {
        get {
            (try? JSONDecoder().decode(Set<String>.self, from: usedAnimationsData)) ?? []
        }
        set {
            usedAnimationsData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }

    private let allPhrases: [String] = [
        "Ам ам - ам ам",
        "Сливы, яблоки на зеленом",
        "Миллион двести на балансе",
        "+rep",
        "+25",
        "Ты сделаешь мне ням-ням иначе я опухну с голоду",
        "Мотивацию надо поднять",
        "22.000.000$ за три грёбанных часа",
        "Настя К. наверное никогда не узнает, что она мне нравится",
        "VI KA",
        "+15 рублей",
        "~Ребята... давайте сюда свои деньги~",
        "Вы великолепны",
        "50к в сумке у папы",
        "Победа вместо обеда",
        "У нас есть печенько",
        "За улетность денег не беру",
        "Вкус победы",
        "Обед прошёл успешно",
        "Почти шведский стол",
        "Лизе респект",
        "Бизнес, ничего личного",
        "Welcome to the club buddy",
        "+вайбик",
        "Как ты можешь ненавидеть чувака...",
        "Работаем",
        "Привет Саша 0_0",
        "Тупо кайф",
        "Приятного аппетита мне",
        "Кто молодец? Ты молодец",
        "Топ 15 адекватных поступков",
        "Очень мило с вашей стороны",
        "Приятно удивлен",
        "Прибавка к пенсии",
        "Плюс мораль",
        "Let him cook",
        "Не думал, что это сработает",
        "Norm - мечты сбываются",
        "Копейка на глазах родилась",
        "Деньги из воздуха?",
        "Разраб - он такой один",
        "Инвестиции окупятся",
        "Stonks",
        "Копейка рубль бережет",
        "Money, money, money",
        "Работа не волк, работа - ворк",
        "Money talks",
        "Капитал растет",
        "Рабочая схемка походу",
        "20% фраз сгенерено ГПТ",
        "Теперь я туда-сюда миллионер?",
        "Финансовая независимость ближе",
        "Мечта о богатстве сбывается",
        "Добавлять фразы? Отзывы пишите пж",
        "На дошик хватит наверное"
    ]

    private let allAnimations: [String] = [
        "avocado",
        "barbeque",
        "broccoli",
        "burger1",
        "burger2",
        "burger3",
        "burger4",
        "burger5",
        "burito",
        "coctail",
        "coffee1",
        "coffee2",
        "coke",
        "cookie",
        "donut",
        "fries1",
        "fries2",
        "hotdog",
        "mushroom",
        "orange",
        "pizza",
        "potato",
        "pumpkin",
        "saladCat",
        "taco",
        "toaster"
    ]

    func generatePhrase() {
        let available = allPhrases.filter { !usedPhrases.contains($0) }

        if available.isEmpty {
            usedPhrases.removeAll()
            generatePhrase()
            return
        }

        let phrase = available.randomElement()!
        usedPhrases.insert(phrase)
        currentPhrase = phrase
    }

    func generateAnimation() {
        let available = allAnimations.filter { !usedAnimations.contains($0) }

        if available.isEmpty {
            usedAnimations.removeAll()
            generateAnimation()
            return
        }

        let animation = available.randomElement()!
        usedAnimations.insert(animation)
        currentAnimation = animation
    }

    func reset() {
        usedPhrases.removeAll()
        currentPhrase = nil
    }
}
