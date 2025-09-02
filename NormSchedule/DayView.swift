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
    @Binding var pinSched : [[Bool:UUID]]

    let dayKey: String

    init(daySched: Binding<[[Lesson]]>, pinSched: Binding<[[Bool:UUID]]>, dayKey: String) {
        self._daySched = daySched
        self._pinSched = pinSched
        self.dayKey = dayKey
    }

    var body: some View {
        ScrollView {
            LazyVStack {
                CachedYandexAdaptiveBanner(
                    key: "\(dayKey)_top",
                    adUnitID: "demo-banner-yandex",
                    padding: 10
                )
                .frame(height: 50)
                .background {
                    ZStack {
                        Color.gray.opacity(0.08)
                        Text("Реклама помогает поддерживать проект")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 10)
                }
                let halfIndex = daySched.count / 2
                ForEach(0..<halfIndex, id: \.self) { index in
                    LessonView(lessons: $daySched[index], pinned: $pinSched[index]) {
                        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                            withAnimation {
                                daySched.remove(at: index)
                                pinSched.remove(at: index)
                            }
                        }
                    }
                    //.frame(height: 210) //TODO: Регулирует вертикальный пробел между [Lesson] элементами, а также не дает им быть меньшего чем это задано в LesoonView размера (там frame height 140 тоже стоит) это странная хуйня и мне это не нравится, но без нее уроки сворачивает нахуй -> переместилось в LessonView
                }
                if daySched.count > 2 {
                    CachedYandexAdaptiveBanner(
                        key: "\(dayKey)_middle",
                        adUnitID: "demo-banner-yandex",
                        padding: 10
                    )
                    .frame(height: 50)
                    .background {
                        ZStack {
                            Color.gray.opacity(0.08)
                            Text("Реклама помогает поддерживать проект")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 10)
                    }
                }
                ForEach(halfIndex..<daySched.count, id: \.self) { index in
                    LessonView(lessons: $daySched[index], pinned: $pinSched[index]) {
                        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                            withAnimation {
                                daySched.remove(at: index)
                                pinSched.remove(at: index)
                            }
                        }
                    }
                }
                CachedYandexAdaptiveBanner(
                    key: "\(dayKey)_bottom",
                    adUnitID: "demo-banner-yandex",
                    padding: 10
                )
                .frame(height: 50)
                .background {
                    ZStack {
                        Color.gray.opacity(0.08)
                        Text("Реклама помогает поддерживать проект")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 10)
                }

            }
            .padding(settingsManager.dayTabBarPosition ? .top : .bottom, 80) //Вот тут можно регулировать отступ, по хорошему менять при изменении по комменту указанному выше
        }
    }
}

#Preview {
    //dayName: "Monday", daySched: SchedModel().items[0].schedule["Monday"] ?? []
    DayView(daySched: .constant([[Lesson(timeStart: 30000/*Date(timeIntervalSince1970: 30000)*/, timeEnd: 30000/*Date(timeIntervalSince1970: 32000)*/, type: "пр.", subgroup: "Цифровая кафедра", parity: [true: "чис."], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424"), Lesson(timeStart: 30000/*Date(timeIntervalSince1970: 30000)*/, timeEnd: 30000/*Date(timeIntervalSince1970: 32000)*/, type: "пр.", subgroup: "АУЕ урок", parity: [true: "чис."], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424")],
                                 [Lesson(timeStart: 30000/*Date(timeIntervalSince1970: 30000)*/, timeEnd: 30000/*Date(timeIntervalSince1970: 32000)*/, type: "пр.", subgroup: "Цифровая кафедра", parity: [true: "чис."], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424")]]), pinSched: .constant([[Bool:UUID](),[Bool:UUID]()]), dayKey: "1")
    .environmentObject(SettingsManager())
}
