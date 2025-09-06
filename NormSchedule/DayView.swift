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
                adBanner("\(dayKey)_top")
                let halfIndex = daySched.count / 2
                ForEach(Array(daySched.prefix(halfIndex).enumerated()), id: \.element.first?.id) { index, element in // TODO: ЕБАНАЯ ДРИСНЯ! ФИКСИТЬ ТОЛЬКО identifier на каждый такой массив или искать другой вариант, потому что 3д массив походу был ошибкой
                    lessonView(at: index)
                }
                if daySched.count > 2 {
                    adBanner("\(dayKey)_middle")
                }
//                ForEach(daySched.indices.dropFirst(halfIndex), id: \.self) { index in
//                    lessonView(at: index)
//                        .id("lesson_group_\(index)_\(daySched[index].first?.id.uuidString ?? "")")
//                }
                ForEach(Array(daySched.dropFirst(halfIndex).enumerated()), id: \.element.first?.id) { offset, _ in
                    let actualIndex = halfIndex + offset
                    lessonView(at: actualIndex)
                }
                adBanner("\(dayKey)_bottom")
            }
            .padding(settingsManager.dayTabBarPosition ? .top : .bottom, 80) //Вот тут можно регулировать отступ, по хорошему менять при изменении по комменту указанному выше
        }

        
    }

    private func lessonView(at index: Int) -> some View {
        guard index < daySched.count && index < pinSched.count else {
            return AnyView(EmptyView()) // или другой placeholder
        }

        return AnyView(
            LessonView(lessons: $daySched[index], pinned: $pinSched[index]) {
                withAnimation {
                    if index < daySched.count && index < pinSched.count { // TODO: Хз почему но если удалять занятия то в какой то момент вылетает outOfRange
                        daySched.remove(at: index)
                        pinSched.remove(at: index)
                    }
                }
            }
            //.frame(height: 210) //TODO: Регулирует вертикальный пробел между [Lesson] элементами, а также не дает им быть меньшего чем это задано в LesoonView размера (там frame height 140 тоже стоит) это странная хуйня и мне это не нравится, но без нее уроки сворачивает нахуй -> переместилось в LessonView
        )
    }

    private func adBanner(_ key: String) -> some View {
        CachedYandexAdaptiveBanner(
            key: key,
            adUnitID: "R-M-15844742-2",
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
}

#Preview {
    //dayName: "Monday", daySched: SchedModel().items[0].schedule["Monday"] ?? []
    DayView(daySched: .constant([[Lesson(timeStart: 30000/*Date(timeIntervalSince1970: 30000)*/, timeEnd: 30000/*Date(timeIntervalSince1970: 32000)*/, type: "пр.", subgroup: "Цифровая кафедра", parity: [true: "чис."], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424"), Lesson(timeStart: 30000/*Date(timeIntervalSince1970: 30000)*/, timeEnd: 30000/*Date(timeIntervalSince1970: 32000)*/, type: "пр.", subgroup: "АУЕ урок", parity: [true: "чис."], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424")],
                                 [Lesson(timeStart: 30000/*Date(timeIntervalSince1970: 30000)*/, timeEnd: 30000/*Date(timeIntervalSince1970: 32000)*/, type: "пр.", subgroup: "Цифровая кафедра", parity: [true: "чис."], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424")]]), pinSched: .constant([[Bool:UUID](),[Bool:UUID]()]), dayKey: "1")
    .environmentObject(SettingsManager())
}
