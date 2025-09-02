//
//  ContentView.swift
//  NormScheduleCompanion Watch App
//
//  Created by Кирилл Архипов on 03.03.2025.
//

import SwiftUI

struct ContentView: View {
    let days = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    @State private var selectedDayButton: String = "Пн"
    @State private var selectedDayTab: String = "Пн"
    @EnvironmentObject var provider : WCProvider
    @EnvironmentObject var settingsManager : SettingsManager
    //    @Bindable var groupSchedule : GroupSched

    //    init(initialDay: String = "Пн", groupSchedule: GroupSched)
    //        self._selectedDayButton = State(initialValue: initialDay)
    //        self._selectedDayTab = State(initialValue: initialDay)
    //        self.groupSchedule = groupSchedule
    //    }

    var body: some View {
        if (provider.receivedSchedule.schedule.isEmpty) {
            Spacer()
            VStack {
                Text("Похоже у вас пока нет расписания на часах")
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)
                    .fontWeight(.bold)
                Text("Выберите его в настройках на вашем iPhone")
                    .font(.system(size: 12))
                    .fontWeight(.light)
                    .multilineTextAlignment(.center)
                Text("убедитесь что устройства связаны во время выбора")
                    .font(.system(size: 12))
                    .opacity(0.5)
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
        else {
            TabView (selection: $selectedDayTab) {
                ForEach(days, id: \.self) { day in
                    let index = days.firstIndex(of: day) ?? 0
                    VStack {
                        if (!provider.receivedSchedule.schedule.indices.contains(index) || provider.receivedSchedule.schedule[index].flatMap { $0 }.isEmpty) {
                            VStack {
                                Text("В этот день занятий вроде нет")
                                    .font(.headline)
                                    .multilineTextAlignment(.center)
                                    .fontWeight(.bold)
                                Text("Кайф")
                            }
                        }
                        else {
                            DayView(day: day, daySched: provider.receivedSchedule.schedule[index],
                                    pinSched: Binding(
                                        get: { dayViewErrorBlockator(with: index) },
                                        set: { if provider.receivedSchedule.pinSchedule.indices.contains(index) { provider.receivedSchedule.pinSchedule[index] = $0 } }
                                    )
                            )
                            .tag(day)
                        }
                    }
                    .ignoresSafeArea()
                }
            }
            .onChange(of: selectedDayTab, { _, newTab in
                selectedDayButton = newTab
            })
            .onAppear {
                let currentDay = settingsManager.recalcCurrDay()
                selectedDayButton = currentDay
                selectedDayTab = currentDay
                //selectedDayTabNum = days.firstIndex(of: currentDay) ?? 0
            }
        }
    }
    private func synchronizeTabView(with day: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            selectedDayTab = day
            //selectedDayTabNum = days.firstIndex(of: day) ?? 0
        }
    }
    private func dayViewErrorBlockator(with index: Int) -> [[Bool : UUID]] {
        if provider.receivedSchedule.schedule.indices.contains(index) {
            let scheduleCount = provider.receivedSchedule.schedule[index].count
            if provider.receivedSchedule.pinSchedule.indices.contains(index) {
                let currentPins = provider.receivedSchedule.pinSchedule[index]
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
    ContentView()
}
