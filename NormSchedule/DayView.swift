//
//  DayView.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 15.03.2024.
//

import SwiftUI

struct DayView: View {
    var daySched : [[Lesson]]
    @EnvironmentObject var settingsManager: SettingsManager
    @Binding var pinSched : [[Bool:Int]]

    var body: some View {
        ScrollView {
            VStack {
                ForEach(daySched.indices, id: \.self) { index in
                    LessonView(lessons: daySched[index], pinned: $pinSched[index])
                        .frame(height: 200)
                }
            }
            .padding(settingsManager.dayTabBarPosition ? .top : .bottom, 80)
        }
    }
}

#Preview {
    //dayName: "Monday", daySched: SchedModel().items[0].schedule["Monday"] ?? []
    DayView(daySched: [[Lesson(timeStart: 30000/*Date(timeIntervalSince1970: 30000)*/, timeEnd: 30000/*Date(timeIntervalSince1970: 32000)*/, type: "пр.", subgroup: "Цифровая кафедра", parity: [true: "чис."], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424"), Lesson(timeStart: 30000/*Date(timeIntervalSince1970: 30000)*/, timeEnd: 30000/*Date(timeIntervalSince1970: 32000)*/, type: "пр.", subgroup: "АУЕ урок", parity: [true: "чис."], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424")],
                       [Lesson(timeStart: 30000/*Date(timeIntervalSince1970: 30000)*/, timeEnd: 30000/*Date(timeIntervalSince1970: 32000)*/, type: "пр.", subgroup: "Цифровая кафедра", parity: [true: "чис."], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424")]], pinSched: .constant([[true:1, false:1],[true:0, false:0]]))
    .environmentObject(SettingsManager())
}
