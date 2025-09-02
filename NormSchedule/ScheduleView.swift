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
    @EnvironmentObject var settingsManager: SettingsManager
    @ObservedObject var provider = WCProvider.shared

    init(initialDay: String = "Пн", groupSchedule: GroupSched) {
        UIPageControl.appearance().currentPageIndicatorTintColor = .blue
        UIPageControl.appearance().pageIndicatorTintColor = .lines
        UIPageControl.appearance().tintColor = .lines
        let currentDay = SettingsManager.shared.recalcCurrDay()
        self._selectedDayButton = State(initialValue: currentDay)
        self._selectedDayTab = State(initialValue: currentDay)
        self.groupSchedule = groupSchedule
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
            if (groupSchedule.schedule.isEmpty) {
                Spacer()
                VStack (spacing: 10) {
                    Text("Похоже у вас пока нет расписания")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .fontWeight(.bold)
                    Text("Перейдите в настройки чтобы получить его")
                    Text("Если расписание выбрано, но не отображается, проверьте сайт вуза, возможно там тоже пусто :)")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }
                Spacer()
            }
            else {
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
        }.ignoresSafeArea()
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
                              )
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
