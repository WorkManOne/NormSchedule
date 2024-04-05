//
//  ContentView.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 14.03.2024.
//

import SwiftUI

//struct ContentView: View {
//    let days = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
//    
//    @State var selected = "Пн"
//    init() {
//        UIPageControl.appearance().currentPageIndicatorTintColor = .blue
//        UIPageControl.appearance().pageIndicatorTintColor = .lines
//        UIPageControl.appearance().tintColor = .lines
//    }
//    
//    @StateObject var settingsManager = SettingsManager()
//    @ObservedObject var Sched = SchedModel()
//    
//    var body: some View {
//        
//        TabView {
//            VStack {
//                HStack {
//                    ForEach (days, id: \.self) { day in
//                        Button(action: {selected = day}) {
//                            Text(day)
//                                .font(.headline)
//                                .foregroundStyle(selected == day ? .lines : .gray)
//                        }
//                        .padding(.horizontal, 12)
//                        .overlay(RoundedRectangle(cornerRadius: 5).stroke().frame(height: 35))
//                        
//                        .foregroundStyle(selected == day ? .lines : .lines.opacity(0.5))
//                        
//                        
//                    }
//                }.padding(.top, 20)
//                    
//                
//                ForEach(Sched.items[0].schedule.indices, id: \.self) { index in
//                    if (days.firstIndex(of: selected)  == index) {
//                        DayView(daySched: Sched.items[0].schedule[index], pinSched: Sched.items[0].pinSchedule[index])
//                            .environmentObject(settingsManager)
//                    }
//                }
//            }.tabItem { 
//                Image(systemName: "book.pages.fill").imageScale(.large)}
//            
//            List {
//                Toggle(isOn: $settingsManager.isEvenWeek, label: {
//                    Text("Четная неделя")
//                        .frame(alignment: .center)
//                    Text("Оставьте выключенным, если у вас такого нет")
//                        .foregroundStyle(.gray)
//                        //.font(.caption)
//                        .frame(width: 190)
//                })
//            }.tabItem { Image(systemName: "gear") }
//        }.tabViewStyle(DefaultTabViewStyle())//.tabViewStyle()
//        
//    }
//}

struct ContentView: View {
    let days = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    let parityNames = ["Чет", "Нечет", "Нет"]
    @State private var parity = "Нет"
    
    @State private var selected = "Пн"
    
    @ObservedObject var settingsManager = SettingsManager()
    @ObservedObject var Sched = SchedModel()
    
    init() {
        UIPageControl.appearance().currentPageIndicatorTintColor = .blue
        UIPageControl.appearance().pageIndicatorTintColor = .lines
        UIPageControl.appearance().tintColor = .lines
        self._selected = State(wrappedValue: Sched.currDay)
    }
    
    
    
    var body: some View {
        
        TabView {
            VStack {
                HStack {
                    ForEach (days, id: \.self) { day in
                        Button(action: {selected = day}) {
                            Text(day)
                                .font(.headline)
                                .foregroundStyle(selected == day ? .lines : .gray)
                        }
                        .padding(.horizontal, 12)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke().frame(height: 35))
                        .foregroundStyle(selected == day ? .lines : .lines.opacity(0.5))
                    }
                }.padding(.top, 20)
                Spacer()
                if (Sched.items.isEmpty || Sched.items[Sched.currItem].schedule.isEmpty) {
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
                    TabView(selection: $selected) {
                        ForEach(Sched.items[Sched.currItem].schedule.indices, id: \.self) { day in
                            DayView(daySched: Sched.items[Sched.currItem].schedule[day], pinSched: $Sched.items[Sched.currItem].pinSchedule[day])
                                .environmentObject(settingsManager)
                                .tag(days[day])
                            
                        }
                    }
                    .onChange(of: Sched.currDay) {
                        selected = Sched.currDay
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }.tabItem { Image(systemName: "book.pages.fill").imageScale(.large) }
                NavigationStack {
                    Toggle(isOn: $settingsManager.isEvenWeek, label: {
                        Text("Четная неделя")
                            .frame(alignment: .center)
                        Text("Оставьте выключенным, если у вас такого нет")
                            .foregroundStyle(.gray)
                            .frame(width: 190)
                    })
                    .onChange(of: settingsManager.isEvenWeek) {
                        Sched.pinnedReform()
                    }
                    
                    Picker(selection: $parity, label: Text("Четность недели")) {
                        ForEach(parityNames, id: \.self) { name in
                            Text(name).tag(name)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    NavigationLink(destination: SchedPickerView(Sched: Sched), label: {Text("Настройка расписания").padding().background(.lines).foregroundStyle(.white)})
                }.tabItem { Image(systemName: "gear") }
        }
        .onAppear {
            Sched.recalcCurrDay()
        }
        //.tabViewStyle(DefaultTabViewStyle())//.tabViewStyle()
        
    }
}

#Preview {
    ContentView()
}
