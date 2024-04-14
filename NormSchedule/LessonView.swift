//
//  LessonView.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 16.03.2024.
//

import SwiftUI

struct LessonView: View {
    var lessons : [Lesson]
    @Binding var pinned : Int
    @State private var active : Int
    //@State var isShown = true
    
    @EnvironmentObject var settingsManager: SettingsManager
    
    init(lessons: [Lesson], pinned: Binding<Int>) {
        self.lessons = lessons
        self._pinned = pinned
        self._active = State(wrappedValue: pinned.wrappedValue)
    }
    
    var body: some View {
        TabView (selection: $active) {
            ForEach(Array(lessons.enumerated()), id: \.element.id) { index, lesson in
                VStack {
                    HStack (alignment: .center) {
                        Text(lesson.subgroup)
                        Spacer()
                        Text("\(lesson.timeStart) - \(lesson.timeEnd)")
                        Spacer()
                        Text(lesson.type)
                        Image(systemName: "pin.fill")
                            .foregroundStyle(.blue)
                            .opacity(index == pinned ? 1 : 0)
                    }//.padding(.top, 5)
                    HStack (alignment: .center) {
                        Text(lesson.name)
                            .padding()
                            .multilineTextAlignment(.center)
                    }
                    HStack (alignment: .center) {
                        Text(lesson.teacher)
                        Spacer()
                        if !lesson.parity.isEmpty {
                            if let firstParity = lesson.parity.first {
                                Text(firstParity.value)
                                    .foregroundColor(.red)
                            }
                            else { Text("") }
                        }
                        else { Text("") }
                        Spacer()
                        Text(lesson.place)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 140)
                .padding(.bottom)
                .padding()
                .overlay(Rectangle().frame(height: 1).foregroundColor(.lines), alignment: .top)
                .overlay(Rectangle().frame(height: 1).foregroundColor(.lines), alignment: .bottom)
                .opacity((lesson.parity.keys.contains(true) && settingsManager.isEvenWeek == 1 || lesson.parity.keys.contains(false) && settingsManager.isEvenWeek == 2 || lesson.parity.isEmpty || settingsManager.isEvenWeek == 0) ? 1 : 0.4)
                .tag(index)
                .onTapGesture(count: 2) { pinned = active }
            }
        }.onChange(of: pinned) { active = pinned }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        
    }
}

#Preview {
    LessonView(lessons: [Lesson(timeStart: "08:20", timeEnd: "09:50", type: "пр.", subgroup: "Цифровая кафедра", parity: [true: "чет."], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424"), Lesson(timeStart: "08:20", timeEnd: "09:50", type: "пр.", subgroup: "АУЕ урок", parity: [:], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424"), Lesson(timeStart: "08:20", timeEnd: "09:50", type: "пр.", subgroup: "АУЕ урок", parity: [false: "знам."], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424")], pinned: .constant(1))
        .environmentObject(SettingsManager())
}
