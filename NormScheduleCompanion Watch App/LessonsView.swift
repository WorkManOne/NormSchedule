//
//  LessonView.swift
//  NormScheduleCompanion Watch App
//
//  Created by Кирилл Архипов on 03.03.2025.
//

import Foundation
import SwiftUI

struct LessonsView: View {
    var lessons : [Lesson]
    @EnvironmentObject var settingsManager: SettingsManager
    @Binding var pinned : [Bool:Int]
    @State private var active = 0
    @State private var isShowingDetail = false
    
    var body: some View {
        Button {
            isShowingDetail.toggle()
        } label: {
            if lessons.indices.contains(active) { //TODO: Еще один бермудский треугольник SwiftUI, то же условие (уже 2 штуки по коду) чтобы не сыпало ошибку при обновлении расписания с телефона
                LessonsPreviewView(
                    lesson: lessons[active],
                    isPinnedTrue: active == pinned[true],
                    isPinnedFalse: active == pinned[false],
                    isShown: (
                        lessons[active].parity.keys.contains(true) && settingsManager.isEvenWeek == 1 ||
                        lessons[active].parity.keys.contains(false) && settingsManager.isEvenWeek == 2 ||
                        lessons[active].parity.isEmpty ||
                        settingsManager.isEvenWeek == 0
                    )
                )
            }
        }
        .sheet(isPresented: $isShowingDetail) {
            List { //ScrollView looks worse, ux better
                ForEach(Array(lessons.enumerated()), id: \.element.id) { index, lesson in
                    LessonDetailView(lesson: lesson, isPinnedTrue: index == pinned[true], isPinnedFalse: index == pinned[false],
                                     isShown: (lesson.parity.keys.contains(true) && settingsManager.isEvenWeek == 1 || lesson.parity.keys.contains(false) && settingsManager.isEvenWeek == 2 || lesson.parity.isEmpty || settingsManager.isEvenWeek == 0))
                    .tag(index)
                }
            }
        }
        .onAppear {
            if (settingsManager.isEvenWeek == 2) {
                active = pinned[false] ?? 0
            }
            else {
                active = pinned[true] ?? 0
            }
        }
        .onChange(of: settingsManager.isEvenWeek) {
            if (settingsManager.isEvenWeek == 2) {
                active = pinned[false] ?? 0
            }
            else {
                active = pinned[true] ?? 0
            }
        }
    }
}


#Preview {
    LessonsView(lessons: [Lesson(timeStart: 30000/*Date(timeIntervalSince1970: 30000)*/, timeEnd: 32000/*Date(timeIntervalSince1970: 32000)*/, type: "пр.", subgroup: "Цифровая кафедра", parity: [true: "чет."], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424"),
                         Lesson(timeStart: 30000/*Date(timeIntervalSince1970: 30000)*/, timeEnd: 30000/*Date(timeIntervalSince1970: 32000)*/, type: "пр.", subgroup: "АУЕ урок", parity: [:], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424")], pinned: .constant([true:1, false:0]))
        .environmentObject(SettingsManager())
}
