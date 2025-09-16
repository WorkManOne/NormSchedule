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
    @Binding var pinned : [Bool:UUID]
    @State private var activeUUID: UUID? = nil
    @State private var selectedLesson: Lesson? = nil
    @State private var showVisibilitySettings = false
    var onRemoveLastLesson: (() -> Void)?
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
        TabView (selection: $activeUUID) {
            ForEach(lessons) { lesson in
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
                                HStack (alignment: .top) {
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
                                                .opacity(lesson.id == pinned[true] ? 0.75 : 0)
                                            Image(systemName: "pin.fill")
                                                .foregroundStyle(.red)
                                                .opacity(lesson.id == pinned[false] ? 0.75 : 0)
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
                                HStack (alignment: .bottom) {
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
//                        VStack { // MARK: Отладка
//                            Text("\(lesson.id)")
//                                .foregroundStyle(.blue)
//                            Text("\(pinned[true])")
//                                .foregroundStyle(.red)
//                            Text("\(pinned[false])")
//                                .foregroundStyle(.red)
//                        }
                    }
                    .opacity((lesson.parity.keys.contains(true) && settingsManager.isEvenWeek == 1 || lesson.parity.keys.contains(false) && settingsManager.isEvenWeek == 2 || lesson.parity.isEmpty || settingsManager.isEvenWeek == 0) ? 1 : 0.4)
                    .frame(height: allHidden ? 50 : 180)
                    .overlay(
                        Color.clear
                            .contentShape(RoundedRectangle(cornerRadius: 25))
                            .contextMenu(menuItems: { //TODO: Важное замечание: происходит странный баланс между переменными active и index? Какую же все таки использовать. Так например active не всегда правильно переопределяется при скрытии пар, но помогает поместить контекстное меню куда угодно! Контекстное меню ломает анимацию при скрытии!
                                Button(action: {
                                    if lesson.parity.keys.contains(false) {
                                        pinned[false] = activeUUID
                                    }
                                    else if lesson.parity.keys.contains(true) {
                                        pinned[true] = activeUUID
                                    }
                                    else {
                                        pinned[true] = lesson.id
                                        pinned[false] = lesson.id
                                    }
                                }) {
                                    Text("Закрепить")
                                    Image(systemName: "pin.fill")
                                }
                                Button(action: {
                                    selectedLesson = lesson // TODO: Временный фикс гонок когда урок еще не успел установится и появляется пустое окно
                                }) {
                                    Text("Подробнее")
                                    Image(systemName: "info.circle")
                                }
                                Button {
                                    withAnimation {
                                        if let index = lessons.firstIndex(where: {$0.id == lesson.id} ) {
                                            lessons[index].isHidden.toggle()
                                        }
                                    }
                                } label: {
                                    Label(
                                        lesson.isHidden ? "Показать пару" : "Скрыть пару",
                                        systemImage: lesson.isHidden ? "eye" : "eye.slash"
                                    )
                                }
                                Button {
                                    showVisibilitySettings = true
                                } label: {
                                    Label("Видимость и порядок", systemImage: "list.bullet")
                                }
                                Button {
                                    withAnimation {
                                        let newLesson = Lesson(timeStart: lessons.first?.timeStart ?? 0, timeEnd: lessons.first?.timeEnd ?? 0, name: "Новая пара")
                                        lessons.append(newLesson)
                                        activeUUID = newLesson.id
                                    }
                                } label: {
                                    Label("Добавить пару", systemImage: "plus.circle")
                                }
                                Button(role: .destructive) {
                                    withAnimation {
                                        if pinned[true] == lesson.id {
                                            pinned[true] = nil
                                        }
                                        if pinned[false] == lesson.id {
                                            pinned[false] = nil
                                        }
                                        if lessons.count > 1 {
                                            if let index = lessons.firstIndex(where: {$0.id == lesson.id} ) {
                                                lessons.remove(at: index)
                                            }
                                        } else if lessons.count == 1 {
                                            onRemoveLastLesson?()
                                        }
                                    }
                                } label : {
                                    Label("Удалить пару", systemImage: "trash")
                                }

                            }, preview: {
                                LessonCardView(lesson: lesson, allHidden: allHidden, pinned: pinned)
                            })
                    )
                    .tag(lesson.id)
                }
            }
            .padding(.horizontal, 10)
            .onAppear {
                updateActiveLesson()
            }
            .onChange(of: settingsManager.isEvenWeek) {
                withAnimation {
                    updateActiveLesson()
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
        .sheet(item: $selectedLesson) { selected in
            if let index = lessons.firstIndex(where: { $0.id == selected.id }) {
                LessonDetailView(lesson: $lessons[index])
            }
        }
        .sheet(isPresented: $showVisibilitySettings) {
            LessonVisibilityManagementView(lessons: $lessons)
        }
    }

    private func updateActiveLesson() {
        if settingsManager.isEvenWeek == 2 {
            activeUUID = pinned[false] ?? lessons.first?.id
        } else {
            activeUUID = pinned[true] ?? lessons.first?.id
        }
    }
}

#Preview {
    LessonView(lessons: .constant([Lesson(timeStart: 30000/*Date(timeIntervalSince1970: 30000)*/, timeEnd: 30000/*Date(timeIntervalSince1970: 32000)*/, type: "пр.", subgroup: "Цифровая кафедра", parity: [true: "чет."], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424", importance: .high), Lesson(timeStart: 30000/*Date(timeIntervalSince1970: 30000)*/, timeEnd: 30000/*Date(timeIntervalSince1970: 32000)*/, type: "пр.", subgroup: "АУЕ урок", parity: [false: "знам."], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424", importance: .high)]), pinned: .constant([Bool:UUID]()))
        .environmentObject(SettingsManager())
}
