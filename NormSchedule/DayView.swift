//
//  DayView.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 15.03.2024.
//

import SwiftUI

struct DayView: View {
    var daySched : [[Lesson]]
    @Binding var pinSched : [Int]

    var body: some View {
        ScrollView {
            VStack {
                ForEach(daySched.indices, id: \.self) { index in
                    LessonView(lessons: daySched[index], pinned: $pinSched[index])
                        .frame(height: 200)
                }
            }
        }
    }
}

#Preview {
    //dayName: "Monday", daySched: SchedModel().items[0].schedule["Monday"] ?? []
    DayView(daySched: [[Lesson(timeStart: "08:20", timeEnd: "09:50", type: "пр.", subgroup: "Цифровая кафедра", parity: true, name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424"), Lesson(timeStart: "08:20", timeEnd: "09:50", type: "пр.", subgroup: "АУЕ урок", parity: true, name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424"), Lesson(timeStart: "08:20", timeEnd: "09:50", type: "пр.", subgroup: "Цифровая кафедра", parity: true, name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424"), Lesson(timeStart: "08:20", timeEnd: "09:50", type: "пр.", subgroup: "АУЕ урок", parity: true, name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424")],
                       [Lesson(timeStart: "08:20", timeEnd: "09:50", type: "пр.", subgroup: "Цифровая кафедра", parity: true, name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424"), Lesson(timeStart: "08:20", timeEnd: "09:50", type: "пр.", subgroup: "АУЕ урок", parity: true, name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424")]], pinSched: .constant([1,0]))
    .environmentObject(SettingsManager())
}
