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
                        //Text(lesson.subgroup)
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
                        Text(lesson.parity)
                            .foregroundStyle(.red)
                        Spacer()
                        Text(lesson.place)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 140)
                .padding(.bottom)
                .padding()
                .overlay(Rectangle().frame(height: 1).foregroundColor(.lines), alignment: .top)
                .overlay(Rectangle().frame(height: 1).foregroundColor(.lines), alignment: .bottom)
                .opacity((lesson.parity == "чис." && settingsManager.isEvenWeek || lesson.parity == "знам." && !settingsManager.isEvenWeek || lesson.parity == "") ? 1 : 0.4)
                .tag(index)
                .onTapGesture(count: 2) { pinned = active }
            }
        }.onChange(of: pinned) {_ in active = pinned }
        //.onChange(of: pinned) { active = pinned }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        
    }
    
//    func updatePinned() {
//            pinnedActive = pinned
//        }
//        
//        // Вызывается, когда представление появляется на экране
//    func onAppear() {
//        updatePinned()
//    }
}

//func pinUpLesson() {
    //var Sched = SchedModel()
    //Sched.items[0].schedule[]
//}

#Preview {
    LessonView(lessons: [Lesson(timeStart: "08:20", timeEnd: "09:50", type: "пр.", subgroup: "Цифровая кафедра", parity: "чис.", name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424"), Lesson(timeStart: "08:20", timeEnd: "09:50", type: "пр.", subgroup: "АУЕ урок", parity: "", name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424"), Lesson(timeStart: "08:20", timeEnd: "09:50", type: "пр.", subgroup: "АУЕ урок", parity: "знам.", name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424")], pinned: .constant(1))
        .environmentObject(SettingsManager())
}