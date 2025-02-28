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

    init(initialDay: String = "Пн", groupSchedule: GroupSched) {
        UIPageControl.appearance().currentPageIndicatorTintColor = .blue
        UIPageControl.appearance().pageIndicatorTintColor = .lines
        UIPageControl.appearance().tintColor = .lines
        self._selectedDayButton = State(initialValue: initialDay)
        self._selectedDayTab = State(initialValue: initialDay)
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
            groupSchedule.pinnedReform()
        }
    }
    var dayTabBarView: some View {
        ZStack (alignment: settingsManager.dayTabBarPosition ? .top : .bottom) {
            TabBarShape(isTop: settingsManager.dayTabBarPosition)
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
                            .font(.headline)
                            .foregroundStyle(selectedDayButton == day ? .lines : .gray)
                            .padding(.horizontal, 12)
                            .background {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color("frameColor"))
                                    .shadow(color: .gray.opacity(0.5), radius: 1)
                                    .frame(height: 35)
                            }
                            .foregroundStyle(selectedDayButton == day ? .lines : .lines.opacity(0.5))
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
                VStack {
                    Text("Похоже у вас пока нет расписания")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .fontWeight(.bold)
                    Text("Перейдите в настройки чтобы получить его")
                }
                Spacer()
            }
            else {
                TabView(selection: $selectedDayTab) {
                    ForEach(days, id: \.self) { day in
                        let index = days.firstIndex(of: day) ?? 0
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
                                DayView(daySched: groupSchedule.schedule[index],
                                        pinSched: Binding(
                                            get: { dayViewErrorBlockator(with: index) },
                                            set: { if groupSchedule.pinSchedule.indices.contains(index) { groupSchedule.pinSchedule[index] = $0 } }
                                        )
                                )
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
//                InfinitePageView(
//                    selection: $selectedDayTabNum,
//                    before: { correctedIndex(for: $0 - 1) },
//                    after: { correctedIndex(for: $0 + 1) },
//                    view: { index in
//                        VStack {
//                            if (!groupSchedule.schedule.indices.contains(index) || groupSchedule.schedule[index].flatMap { $0 }.isEmpty) {
//                                VStack {
//                                    Text("В этот день занятий вроде нет")
//                                        .font(.headline)
//                                        .multilineTextAlignment(.center)
//                                        .fontWeight(.bold)
//                                    Text("Кайф")
//                                }
//                            }
//                            else {
//                                DayView(daySched: groupSchedule.schedule[index],
//                                        pinSched: Binding(
//                                            get: { dayViewErrorBlockator(with: index) },
//                                            set: { if groupSchedule.pinSchedule.indices.contains(index) { groupSchedule.pinSchedule[index] = $0 } }
//                                        )
//                                )
//                            }
//                        }
//                        .environmentObject(settingsManager)
//                    }
//                ).onChange(of: selectedDayTabNum, { _, newTab in
//                    print("selectedDayTab triggered")
//                    selectedDayButton = days[newTab]
//                })
            }
        }.ignoresSafeArea()
    }

    private func correctedIndex(for index: Int) -> Int {
        let count = days.count
        return (count + index) % count
    }
    private func synchronizeTabView(with day: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            selectedDayTab = day
            //selectedDayTabNum = days.firstIndex(of: day) ?? 0
        }
    }
    private func dayViewErrorBlockator(with index: Int) -> [[Bool : Int]] {
        if groupSchedule.schedule.indices.contains(index) {
            let scheduleCount = groupSchedule.schedule[index].count
            if groupSchedule.pinSchedule.indices.contains(index) {
                let currentPins = groupSchedule.pinSchedule[index]
                if currentPins.count < scheduleCount {
                    return currentPins + Array(repeating: [true: 0, false: 0], count: scheduleCount - currentPins.count)
                } else {
                    return currentPins
                }
            }

            return Array(repeating: [true: 0, false: 0], count: scheduleCount)
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
                                        [Lesson(timeStart: "08:20", timeEnd: "09:50", type: "пр.", subgroup: "Цифровая кафедра", parity: [:], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424"),
                                         Lesson(timeStart: "08:20", timeEnd: "09:50", type: "пр.", subgroup: "Цифровая кафедра", parity: [:], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424")
                                        ],
                                        [Lesson(timeStart: "08:20", timeEnd: "09:50", type: "пр.", subgroup: "Цифровая кафедра", parity: [:], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424")
                                        ],
                                        [Lesson(timeStart: "08:20", timeEnd: "09:50", type: "пр.", subgroup: "Цифровая кафедра", parity: [:], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424")
                                        ]
                                    ]
                                ],
                               pinSchedule:
                                [
                                    [
                                        [true:0, false:0], [true:0, false:0]
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
