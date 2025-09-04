//
//  ScheduleView.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 15.06.2024.
//

import SwiftUI

struct ScheduleView: View {

    let days = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    @State private var selectedDayButton: String = "Пн"
    @State private var selectedDayTab: String = "Пн"
    //@State private var selectedDayTabNum = 0

    @Bindable var groupSchedule : GroupSched
    let hasSelectedSchedule: Bool
    @EnvironmentObject var settingsManager: SettingsManager
    @ObservedObject var provider = WCProvider.shared

    init(groupSchedule: GroupSched, hasSelectedSchedule: Bool) {
        UIPageControl.appearance().currentPageIndicatorTintColor = .blue
        UIPageControl.appearance().pageIndicatorTintColor = .lines
        UIPageControl.appearance().tintColor = .lines
        let currentDay = SettingsManager.shared.recalcCurrDay()
        self._selectedDayButton = State(initialValue: currentDay)
        self._selectedDayTab = State(initialValue: currentDay)
        self.groupSchedule = groupSchedule
        self.hasSelectedSchedule = hasSelectedSchedule
    }

    var body: some View {
        ZStack {
            scheduleView
            VStack {
                if !settingsManager.dayTabBarPosition {
                    Spacer()
                }
                dayTabBarView
                if settingsManager.dayTabBarPosition {
                    Spacer()
                }
            }
        }
        .onAppear {
            let currentDay = settingsManager.recalcCurrDay()
            selectedDayButton = currentDay
            selectedDayTab = currentDay
            //selectedDayTabNum = days.firstIndex(of: currentDay) ?? 0
        }
    }
    var dayTabBarView: some View {
        ZStack (alignment: settingsManager.dayTabBarPosition ? .top : .bottom) {
            TabBarShape(isTop: settingsManager.dayTabBarPosition, isCurveStyle: settingsManager.dayTabBarStyle)
                .fill(Color("appearanceColor"))
                .shadow(color: .black.opacity(0.1), radius: 5)
                .ignoresSafeArea()
                .frame(height: 100)
            HStack {
                Spacer()
                ForEach (days, id: \.self) { day in
                    Button(action: {
                        selectedDayButton = day
                        synchronizeTabView(with: day)
                    }) {
                        Text(day)
                            .font(.system(size: 18))
                            .fontWeight(.bold)
                            .foregroundStyle(selectedDayButton == day ? .lines : .gray)
                            .frame(maxWidth: .infinity)
                            .background {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color("frameColor"))
                                    .shadow(color: .gray.opacity(0.5), radius: 1)
                                    .frame(height: 35)
                            }
                            //.foregroundStyle(selectedDayButton == day ? .lines : .lines.opacity(0.5))
                    }
                }
                Spacer()
            }
            .padding(settingsManager.dayTabBarPosition ? .top : .bottom, 20)
        }
    }
    var scheduleView: some View {
        VStack {
            if !hasSelectedSchedule {
                Spacer()
                VStack(spacing: 20) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)

                    Text("Расписание не выбрано")
                        .font(.headline)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text("Перейдите в настройки чтобы загрузить расписание или создать новое")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }
                Spacer()

            } else if groupSchedule.schedule.isEmpty {
                Spacer()
                VStack(spacing: 15) {
                    Image(systemName: "book.pages")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)

                    Text("Расписание пустое")
                        .font(.headline)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text("В выбранном расписании пока нет занятий")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)

                    Text("Если расписание выбрано, но пустое, проверьте сайт вуза, возможно там тоже пусто :)")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)

                    Button {
                        withAnimation {
                            groupSchedule.schedule.append(contentsOf: Array(repeating: [], count: 7 - groupSchedule.schedule.count))
                            groupSchedule.pinSchedule.append(contentsOf: Array(repeating: [], count: 7 - groupSchedule.pinSchedule.count))

                            let newLesson = Lesson(
                                timeStart: 0,
                                timeEnd: 0,
                                name: "Новая пара"
                            )
                            let newPinEntry: [Bool: UUID] = [:]
                            let index = days.firstIndex(of: selectedDayButton) ?? 0
                            groupSchedule.schedule[index].append([newLesson])
                            groupSchedule.pinSchedule[index].append(newPinEntry)
                            groupSchedule.pinnedReform()
                        }
                    } label: {
                        Text("Создать занятие")
                            .foregroundStyle(.appearance)
                            .font(.title2)
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.lines)
                            )
                    }
                }
                Spacer()

            } else {
                TabView(selection: $selectedDayTab) {
                    ForEach(days.indices, id: \.self) { index in
                        let day = days[index]
                        VStack {
                            if (!groupSchedule.schedule.indices.contains(index) || groupSchedule.schedule[index].flatMap { $0 }.isEmpty) {
                                VStack {
                                    Text("В этот день занятий вроде нет")
                                        .font(.headline)
                                        .multilineTextAlignment(.center)
                                        .fontWeight(.bold)
                                    Text("Кайф")
                                    Button {
                                        withAnimation {
                                            groupSchedule.schedule.append(contentsOf: Array(repeating: [], count: 7 - groupSchedule.schedule.count))
                                            groupSchedule.pinSchedule.append(contentsOf: Array(repeating: [], count: 7 - groupSchedule.pinSchedule.count))

                                            let newLesson = Lesson(
                                                timeStart: 0,
                                                timeEnd: 0,
                                                name: "Новая пара"
                                            )
                                            let newPinEntry: [Bool: UUID] = [:]

                                            groupSchedule.schedule[index].append([newLesson])
                                            groupSchedule.pinSchedule[index].append(newPinEntry)
                                            groupSchedule.pinnedReform()
                                        }
                                    } label: {
                                        Text("Создать занятие")
                                            .foregroundStyle(.appearance)
                                            .font(.title2)
                                            .padding(.horizontal)
                                            .padding(.vertical, 10)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(.lines)
                                            )
                                    }
                                }
                            }
                            else {
                                DayView(daySched: $groupSchedule.schedule[index],
                                        pinSched:
//                                            $groupSchedule.pinSchedule[index]

                                            Binding(
                                            get: { dayViewErrorBlockator(with: index) },
                                            set: { if groupSchedule.pinSchedule.indices.contains(index) { groupSchedule.pinSchedule[index] = $0 } }
                                        ),
                                        dayKey: day
                                ) //TODO: DayView пересоздается при перелистывании каждый раз?
                            }
                        }
                        .environmentObject(settingsManager)
                        .tag(day)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onChange(of: selectedDayTab, { _, newTab in
                    selectedDayButton = newTab
                })
            }
        }
        .ignoresSafeArea()
    }

    private func synchronizeTabView(with day: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            selectedDayTab = day
            //selectedDayTabNum = days.firstIndex(of: day) ?? 0
        }
    }
    private func dayViewErrorBlockator(with index: Int) -> [[Bool : UUID]] {
        if groupSchedule.schedule.indices.contains(index) {
            let scheduleCount = groupSchedule.schedule[index].count
            if groupSchedule.pinSchedule.indices.contains(index) {
                let currentPins = groupSchedule.pinSchedule[index]
                if currentPins.count < scheduleCount {
                    let missingCount = scheduleCount - currentPins.count
                    let emptyPins = Array(repeating: [Bool: UUID](), count: missingCount)
                    return currentPins + emptyPins
                } else {
                    return currentPins
                }
            }
            return Array(repeating: [Bool: UUID](), count: scheduleCount)
        }
        return []
    }
}

#Preview {
    ScheduleView(groupSchedule:
                    GroupSched(university: "SSS",
                               faculty: "aaa",
                               group: "1213",
                               date_read: "now",
                               schedule:
                                [
                                    [
                                        [Lesson(timeStart: 30000 /*Date(timeIntervalSince1970: 30000)*/, timeEnd: 30000 /*Date(timeIntervalSince1970: 32000)*/, type: "пр.", subgroup: "Цифровая кафедра", parity: [:], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424"),
                                         Lesson(timeStart: 30000/*Date(timeIntervalSince1970: 30000)*/, timeEnd: 30000 /*Date(timeIntervalSince1970: 32000)*/, type: "пр.", subgroup: "Цифровая кафедра", parity: [:], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424")
                                        ]
                                    ],
                                    [],
                                    [
                                        [Lesson(timeStart: 30000 /*Date(timeIntervalSince1970: 30000)*/, timeEnd: 30000 /*Date(timeIntervalSince1970: 32000)*/, type: "пр.", subgroup: "Цифровая кафедра", parity: [:], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424"),
                                         Lesson(timeStart: 30000/*Date(timeIntervalSince1970: 30000)*/, timeEnd: 30000 /*Date(timeIntervalSince1970: 32000)*/, type: "пр.", subgroup: "Цифровая кафедра", parity: [:], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424")
                                        ]
                                    ]
                                ],
                               pinSchedule:
                                [
                                    [
                                        [true: UUID(), false: UUID()]
                                    ]

                                ]
                              ), hasSelectedSchedule: true
    )
    .environmentObject(SettingsManager())
}
//
//#Preview {
//    ScheduleView(groupSchedule:
//                    GroupSched(
//                        university: "SSS",
//                        faculty: "aaa",
//                        group: "1213",
//                        date_read: "now",
//                        schedule:
//                            [
//                                [
//                                    [Lesson(timeStart: "08:20", timeEnd: "09:50", type: "пр.", subgroup: "Цифровая кафедра", parity: [true: "чис."], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424"),
//                                     Lesson(timeStart: "08:20", timeEnd: "09:50", type: "пр.", subgroup: "АУЕ урок", parity: [true: "чис."], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424"),
//                                     Lesson(timeStart: "08:20", timeEnd: "09:50", type: "пр.", subgroup: "Цифровая кафедра", parity: [true: "чис."], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424"),
//                                     Lesson(timeStart: "08:20", timeEnd: "09:50", type: "пр.", subgroup: "АУЕ урок", parity: [true: "чис."], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424")],
//
//                                    [Lesson(timeStart: "08:20", timeEnd: "09:50", type: "пр.", subgroup: "Цифровая кафедра", parity: [true: "чис."], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424"),
//                                     Lesson(timeStart: "08:20", timeEnd: "09:50", type: "пр.", subgroup: "АУЕ урок", parity: [true: "чис."], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424")]
//                                ]
////                                ,
////                                [
////                                    [Lesson(timeStart: "08:20", timeEnd: "09:50", type: "пр.", subgroup: "Цифровая кафедра", parity: [true: "чис."], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424"),
////                                     Lesson(timeStart: "08:20", timeEnd: "09:50", type: "пр.", subgroup: "АУЕ урок", parity: [true: "чис."], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424")]
////                                ]
//                            ],
//                        pinSchedule: [[[true:1, false:1],[true:0, false:0]]]))
//    .environmentObject(SettingsManager())
//}
