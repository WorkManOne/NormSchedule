//
//  DayView.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 15.03.2024.
//

import SwiftUI

struct DayView: View {
    @Binding var daySched : [[Lesson]]
    @EnvironmentObject var settingsManager: SettingsManager
    @Binding var pinSched : [[Bool:Int]]

    init(daySched: Binding<[[Lesson]]>, pinSched: Binding<[[Bool:Int]]>) {
            self._daySched = daySched
            self._pinSched = pinSched
        print("♻️ DayView инициализирован \(UUID())") // или index
    }

    var body: some View {
        let _ = print("🎯 DayView body - settingsManager изменился?")
        return ScrollView {
            LazyVStack {
                YandexAdaptiveBanner(adUnitID: "demo-banner-yandex", padding: 10)
                    .frame(height: 50)
                ForEach(daySched.indices, id: \.self) { index in
                    LessonView(lessons: $daySched[index], pinned: $pinSched[index])
                        //.frame(height: 210) //TODO: Регулирует вертикальный пробел между [Lesson] элементами, а также не дает им быть меньшего чем это задано в LesoonView размера (там frame height 140 тоже стоит) это странная хуйня и мне это не нравится, но без нее уроки сворачивает нахуй -> переместилось в LessonView
                }
            }
            .padding(settingsManager.dayTabBarPosition ? .top : .bottom, 80) //Вот тут можно регулировать отступ, по хорошему менять при изменении по комменту указанному выше
        }
    }
}

#Preview {
    //dayName: "Monday", daySched: SchedModel().items[0].schedule["Monday"] ?? []
    DayView(daySched: .constant([[Lesson(timeStart: 30000/*Date(timeIntervalSince1970: 30000)*/, timeEnd: 30000/*Date(timeIntervalSince1970: 32000)*/, type: "пр.", subgroup: "Цифровая кафедра", parity: [true: "чис."], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424"), Lesson(timeStart: 30000/*Date(timeIntervalSince1970: 30000)*/, timeEnd: 30000/*Date(timeIntervalSince1970: 32000)*/, type: "пр.", subgroup: "АУЕ урок", parity: [true: "чис."], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424")],
                       [Lesson(timeStart: 30000/*Date(timeIntervalSince1970: 30000)*/, timeEnd: 30000/*Date(timeIntervalSince1970: 32000)*/, type: "пр.", subgroup: "Цифровая кафедра", parity: [true: "чис."], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424")]]), pinSched: .constant([[true:1, false:1],[true:0, false:0]]))
    .environmentObject(SettingsManager())
}
