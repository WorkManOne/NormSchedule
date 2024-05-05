//
//  LessonView.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 16.03.2024.
//

import SwiftUI

struct LessonView: View {
    var lessons : [Lesson]
    @EnvironmentObject var settingsManager: SettingsManager
    @Binding var pinned : [Bool:Int]
    @State private var active = 0
    //@State var isShown = true
    
//    
//    
//    init(lessons: [Lesson], pinned: Binding<[Bool:Int]>) {
//        self.lessons = lessons
//        self._pinned = pinned
//        self._active = State(wrappedValue: 0)
//    }
    
    var body: some View {
        TabView (selection: $active) {
            ForEach(Array(lessons.enumerated()), id: \.element.id) { index, lesson in
                VStack {
                    //Text("\(active) \(pinned[true]!) \(pinned[false]!)")
                    HStack (alignment: .center) {
                        Text(lesson.subgroup)
                        Spacer()
                        Text("\(lesson.timeStart) - \(lesson.timeEnd)")
                        Spacer()
                        Text(lesson.type)
                        ZStack {
                            Image(systemName: "pin.fill")
                                .foregroundStyle(.blue)
                                .opacity(index == pinned[true] ? 0.75 : 0)
                                //.scaleEffect(1.5)
                            Image(systemName: "pin.fill")
                                .foregroundStyle(.red)
                                .opacity(index == pinned[false] ? 0.75 : 0)
                        }
                    }//.padding(.top, 5)
                    HStack (alignment: .center) {
                        Text(lesson.name)
                            .fontWeight(.bold)
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
            }
            .onAppear {
                //print("appeared")
                if (settingsManager.isEvenWeek == 2) {
                    active = pinned[false] ?? 0
                }
                else {
                    active = pinned[true] ?? 0
                }
            }
        }
        
        .onTapGesture(count: 2) {
            //print("tapped \(active)")
            if (lessons[active].parity.keys.contains(false)
                && !lessons.allSatisfy { l in l.parity.keys.contains(false) }) {
                pinned[false] = active
            }
            else if (lessons[active].parity.keys.contains(true)
                     && !lessons.allSatisfy { l in l.parity.keys.contains(true) }) {
                pinned[true] = active
            }
            else {
                pinned[true] = active
                pinned[false] = active
            }
                                        
        }
//        .onChange(of: pinned) {
//            if (settingsManager.isEvenWeek == 2) {
//                active = pinned[false] ?? 0
//            }
//            else {
//                active = pinned[true] ?? 0
//            }
//        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        
    }
}

#Preview {
    LessonView(lessons: [Lesson(timeStart: "08:20", timeEnd: "09:50", type: "пр.", subgroup: "Цифровая кафедра", parity: [true: "чет."], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424"), Lesson(timeStart: "08:20", timeEnd: "09:50", type: "пр.", subgroup: "АУЕ урок", parity: [:], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424"), Lesson(timeStart: "08:20", timeEnd: "09:50", type: "пр.", subgroup: "АУЕ урок", parity: [false: "знам."], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424")], pinned: .constant([true:1, false:0]))
        .environmentObject(SettingsManager())
}
