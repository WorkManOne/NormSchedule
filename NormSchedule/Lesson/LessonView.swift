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
    @State private var showVisibilitySettings = false
    //    @State private var cornerRadius : CGFloat = 25
    //    @State private var frameHeight : CGFloat = 100
    //@State var isShown = true

    //
    //
    //    init(lessons: [Lesson], pinned: Binding<[Bool:Int]>) {
    //        self.lessons = lessons
    //        self._pinned = pinned
    //        self._active = State(wrappedValue: 0)
    //    }

    var body: some View {
        let allHidden = lessons.allSatisfy { $0.isHidden }
        TabView (selection: $active) {
            ForEach(Array(lessons.enumerated()), id: \.element.id) { index, lesson in
                if !lesson.isHidden || (allHidden && lesson == lessons.first) {
                    ZStack {
                        HStack {
                            Spacer()
                        }
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color("frameColor"))
                            .overlay(alignment: .topTrailing) {
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
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .shadow(color: .gray.opacity(0.5), radius: 2)

                        if !allHidden {
                            VStack (alignment: .center) {
                                HStack {
                                    Text(lesson.subgroup)
                                            .frame(maxWidth: .infinity, alignment: .leading)

                                    HStack {
                                        if let icon = lesson.importance.icon {
                                            icon
                                                .foregroundStyle(lesson.importance.iconColor)
                                                .help(lesson.importance.description)
                                        }
                                        Text(lesson.timeString())
                                            .fontWeight(.medium)
                                            .lineLimit(1)
                                            .fixedSize()
                                    }
                                    .frame(maxWidth: .infinity)

                                    HStack(spacing: 4) {
                                        Text(lesson.type)
                                        ZStack {
                                            Image(systemName: "pin.fill")
                                                .foregroundStyle(.blue)
                                                .opacity(index == pinned[true] ? 0.75 : 0)
                                            Image(systemName: "pin.fill")
                                                .foregroundStyle(.red)
                                                .opacity(index == pinned[false] ? 0.75 : 0)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .trailing)
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
                            }
                            .padding(.bottom)
                            .padding()
                        } else {
                            HStack (alignment: .center) {
                                Spacer()
                                Text("\(lesson.timeString())")
                                Spacer()
                            }
                        }
                    }
                    .opacity((lesson.parity.keys.contains(true) && settingsManager.isEvenWeek == 1 || lesson.parity.keys.contains(false) && settingsManager.isEvenWeek == 2 || lesson.parity.isEmpty || settingsManager.isEvenWeek == 0) ? 1 : 0.4)
                    .frame(height: allHidden ? 50 : 180)
                    .overlay(
                        Color.clear
                            .contentShape(RoundedRectangle(cornerRadius: 25))
                            .contextMenu(menuItems: { //TODO: Важное замечание: происходит странный баланс между переменными active и index? Какую же все таки использовать. Так например active не всегда правильно переопределяется при скрытии пар, но помогает поместить контекстное меню куда угодно! Контекстное меню ломает анимацию при скрытии!
                                Button(action: {
                                    if (lessons[index].parity.keys.contains(false)
                                        && !lessons.allSatisfy { l in l.parity.keys.contains(false) }) {
                                        pinned[false] = active
                                    }
                                    else if (lessons[index].parity.keys.contains(true)
                                             && !lessons.allSatisfy { l in l.parity.keys.contains(true) }) {
                                        pinned[true] = active
                                    }
                                    else {
                                        pinned[true] = index
                                        pinned[false] = index
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
                                Button {
                                    withAnimation {
                                        lessons[index].isHidden.toggle()
                                    }
                                } label: {
                                    Label(
                                        lessons[index].isHidden ? "Показать пару" : "Скрыть пару",
                                        systemImage: lessons[index].isHidden ? "eye" : "eye.slash"
                                    )
                                }
                                Button {
                                    showVisibilitySettings = true
                                } label: {
                                    Label("Управление видимостью", systemImage: "list.bullet")
                                }

                            }, preview: {
                                LessonCardView(lesson: lesson, allHidden: allHidden, index: index, pinned: pinned)
                            })
                    )
                    .tag(index)
                }
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
        .frame(height: allHidden ? 55 : 210)
        .tabViewStyle(.page(indexDisplayMode: allHidden ? .never : .automatic))
        .overlay {
            if lessons.filter({ $0.isHidden }).count > 0 && !allHidden {
                    let hiddenCount = lessons.filter { $0.isHidden }.count

                    Text("Ещё \(hiddenCount) скрыт\(hiddenCount == 1 ? "ая пара" : hiddenCount < 5 ? "ые пары" : "ых пар")")
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.secondary.opacity(0.15))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.secondary.opacity(0.3)))
                        .shadow(radius: 2)
                        .padding(.trailing, 16)
                        .padding(.bottom, 6)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                }
            else {
                Text("")
            }
        }
        .sheet(isPresented: $showDetail) {
            LessonDetailView(lesson: $lessons[active])
        }
        .sheet(isPresented: $showVisibilitySettings) {
            LessonVisibilityManagementView(lessons: $lessons)
        }
    }
}

#Preview {
    LessonView(lessons: .constant([Lesson(timeStart: 30000/*Date(timeIntervalSince1970: 30000)*/, timeEnd: 30000/*Date(timeIntervalSince1970: 32000)*/, type: "пр.", subgroup: "Цифровая кафедра", parity: [true: "чет."], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424", importance: .high), Lesson(timeStart: 30000/*Date(timeIntervalSince1970: 30000)*/, timeEnd: 30000/*Date(timeIntervalSince1970: 32000)*/, type: "пр.", subgroup: "АУЕ урок", parity: [false: "знам."], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424", importance: .high)]), pinned: .constant([true:1, false:0]))
        .environmentObject(SettingsManager())
}
