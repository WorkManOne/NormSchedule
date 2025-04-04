//
//  LessonView.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 16.03.2024.
//

import SwiftUI

struct LessonView: View {
    @Binding var lessons : [Lesson] //TODO: Could lead to technical difficulties, non-tested Binding feature, in case: replace with non-binding and at higher levels
    @EnvironmentObject var settingsManager: SettingsManager
    @Binding var pinned : [Bool:Int]
    @State private var active = 0
    @State private var showDetail = false
    //@State var isShown = true
    
//    
//    
//    init(lessons: [Lesson], pinned: Binding<[Bool:Int]>) {
//        self.lessons = lessons
//        self._pinned = pinned
//        self._active = State(wrappedValue: 0)
//    }
    
    var body: some View {
        //let isHidden = lessons.allSatisfy { $0.isHidden }
        TabView (selection: $active) {
            ForEach(Array(lessons.enumerated()), id: \.element.id) { index, lesson in
                VStack (alignment: .center) {
//                    HStack {
//                        Spacer()
//                    }
                    //Text("\(active) \(pinned[true]!) \(pinned[false]!)")
                    //if !isHidden {
                        HStack (alignment: .center) {
                            Text(lesson.subgroup)
                            Spacer()
                            Text("\(lesson.timeString())")
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
                        }
                        Spacer()
                        HStack (alignment: .center) {
                            Text(lesson.name)
                                .fontWeight(.bold)
                                .padding(5)
                                .multilineTextAlignment(.center)
                        }
                        Spacer()
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
                    //}
                }
                .frame(maxWidth: .infinity, maxHeight: 140)
                .padding(.bottom)
                .padding()
                .background {
                    ZStack (alignment: .topTrailing) {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color("frameColor"))
                            //.shadow(color: .gray.opacity(0.5), radius: 2)
                        VStack {
                            HStack {
                                Spacer()
                                if !lesson.note.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    Path { path in
                                        path.move(to: CGPoint(x: 0, y: 0))
                                        path.addLine(to: CGPoint(x: 35, y: 35))
                                        path.addLine(to: CGPoint(x: 35, y: 0))
                                        path.closeSubpath()
                                    }
                                    .fill(Color.yellow)
                                    .frame(width: 35, height: 35)
                                }
                            }
                            Spacer()
                        }
                    }
                    .clipShape (
                        RoundedRectangle(cornerRadius: 25)
                    )
                    .shadow(color: .gray.opacity(0.5), radius: 2)
                }
                .opacity((lesson.parity.keys.contains(true) && settingsManager.isEvenWeek == 1 || lesson.parity.keys.contains(false) && settingsManager.isEvenWeek == 2 || lesson.parity.isEmpty || settingsManager.isEvenWeek == 0) ? 1 : 0.4)
                .contextMenu {
                    Button(action: {
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
                    }) {
                        Text("Закрепить")
                        Image(systemName: "pin.fill")
                    }
                    Button(action: {
                        showDetail = true
                    }) {
                        Text("Подробнее")
                        Image(systemName: "info.circle")
                    }
                    Button(action: {
                        withAnimation {
                            lessons[active].isHidden.toggle()
                        }

                    }) {
                        Text(lessons[active].isHidden ? "Показать пару" : "Скрыть пару")
                        Image(systemName: lessons[active].isHidden ? "eye" : "eye.slash")
                    }

                }
                .tag(index)
            }
            .padding(.horizontal, 10)
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
//        .onChange(of: pinned) {
//            if (settingsManager.isEvenWeek == 2) {
//                active = pinned[false] ?? 0
//            }
//            else {
//                active = pinned[true] ?? 0
//            }
//        }
        .frame(height: /*isHidden ? 20 : */210)
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .sheet(isPresented: $showDetail) {
            DetailLessonView(lesson: $lessons[active])
        }
    }
    
}

#Preview {
    LessonView(lessons: .constant([Lesson(timeStart: 30000/*Date(timeIntervalSince1970: 30000)*/, timeEnd: 30000/*Date(timeIntervalSince1970: 32000)*/, type: "пр.", subgroup: "Цифровая кафедра", parity: [true: "чет."], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424"), Lesson(timeStart: 30000/*Date(timeIntervalSince1970: 30000)*/, timeEnd: 30000/*Date(timeIntervalSince1970: 32000)*/, type: "пр.", subgroup: "АУЕ урок", parity: [false: "знам."], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424")]), pinned: .constant([true:1, false:0]))
        .environmentObject(SettingsManager())
}
