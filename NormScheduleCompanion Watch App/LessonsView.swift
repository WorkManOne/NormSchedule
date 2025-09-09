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
    @Binding var pinned : [Bool: UUID]
    @State private var activeUUID: UUID? = nil
    @State private var activeCollapse: Bool = false
    @State private var isShowingDetail = false
    
    var body: some View {
        Button {
            isShowingDetail.toggle()
        } label: {
            if let activeUUID = activeUUID,
               let activeLesson = lessons.first(where: { $0.id == activeUUID }) {  //TODO: ПРОВЕРИТЬ УБИЛ ЛИ ЭТИМ РЕШЕНИЕМ Я (там вроде надо было удалить последнее расписание) Еще один бермудский треугольник SwiftUI, то же условие (уже 2 штуки по коду) чтобы не сыпало ошибку при обновлении расписания с телефона
                lessonPreview(for: activeLesson, isCollapsed: activeCollapse)
            } else if let firstLesson = lessons.first {
                lessonPreview(for: firstLesson, isCollapsed: activeCollapse)
            }
        }
        //.buttonStyle(.plain)
        .sheet(isPresented: $isShowingDetail) {
            List { //ScrollView looks worse, ux better
                ForEach(Array(lessons.enumerated()), id: \.element.id) { index, lesson in
                    LessonDetailView(
                        lesson: lesson,
                        isPinnedTrue: lesson.id == pinned[true],
                        isPinnedFalse: lesson.id == pinned[false],
                        isShown: (
                            lesson.parity.keys.contains(true) && settingsManager.isEvenWeek == 1 ||
                            lesson.parity.keys.contains(false) && settingsManager.isEvenWeek == 2 ||
                            lesson.parity.isEmpty || settingsManager.isEvenWeek == 0
                        )
                    )
                    .tag(lesson.id)
                }
            }
        }
        .onAppear {
            updateActiveLesson()
        }
        .onChange(of: settingsManager.isEvenWeek) {
            updateActiveLesson()
        }
        .onChange(of: lessons.map { ($0.isHidden) }) {
            updateActiveLesson()
        }
    }

    private func updateActiveLesson() {
        withAnimation {
            let isEvenWeek = settingsManager.isEvenWeek != 2 ? true : false

            if let pinnedId = pinned[isEvenWeek],
               let pinnedLesson = lessons.first(where: { $0.id == pinnedId }),
               !pinnedLesson.isHidden {
                activeUUID = pinnedId
                activeCollapse = false
                return
            }

            let oppositeParity = !isEvenWeek
            if let pinnedId = pinned[oppositeParity],
               let pinnedLesson = lessons.first(where: { $0.id == pinnedId }),
               !pinnedLesson.isHidden {
                activeUUID = pinnedId
                activeCollapse = false
                return
            }

            if let firstVisible = lessons.first(where: { !$0.isHidden }) {
                activeUUID = firstVisible.id
                activeCollapse = false
                return
            }

            activeUUID = lessons.first?.id
            activeCollapse = true
        }
    }

    private func lessonPreview(for lesson: Lesson, isCollapsed: Bool) -> LessonsPreviewView {
        LessonsPreviewView(
            lesson: lesson,
            isPinnedTrue: lesson.id == pinned[true],
            isPinnedFalse: lesson.id == pinned[false],
            isShown: isLessonShown(lesson),
            isCollapsed: isCollapsed
        )
    }

    private func isLessonShown(_ lesson: Lesson) -> Bool {
        lesson.parity.keys.contains(true) && settingsManager.isEvenWeek == 1 ||
        lesson.parity.keys.contains(false) && settingsManager.isEvenWeek == 2 ||
        lesson.parity.isEmpty ||
        settingsManager.isEvenWeek == 0
    }
}


#Preview {
    LessonsView(lessons: [Lesson(timeStart: 30000/*Date(timeIntervalSince1970: 30000)*/, timeEnd: 32000/*Date(timeIntervalSince1970: 32000)*/, type: "пр.", subgroup: "Цифровая кафедра", parity: [true: "чет."], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424"),
                          Lesson(timeStart: 30000/*Date(timeIntervalSince1970: 30000)*/, timeEnd: 30000/*Date(timeIntervalSince1970: 32000)*/, type: "пр.", subgroup: "АУЕ урок", parity: [:], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424")], pinned: .constant([Bool: UUID]()))
        .environmentObject(SettingsManager())
}
