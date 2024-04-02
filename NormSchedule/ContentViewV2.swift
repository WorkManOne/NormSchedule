//
//  ContentView.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 14.03.2024.
//

import SwiftUI

struct ContentView: View {
    let days = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    
    @State var selected = 0
    init() {
        UIPageControl.appearance().currentPageIndicatorTintColor = .blue
        UIPageControl.appearance().pageIndicatorTintColor = .lines
        UIPageControl.appearance().tintColor = .lines
    }
    
    @StateObject var settingsManager = SettingsManager()
    @ObservedObject var Sched = SchedModel()
    
    var body: some View {
        
        TabView {
            VStack {
                HStack {
                    ForEach (days.indices, id: \.self) { day in
                        Button(action: {selected = day}) {
                            Text(days[day])
                                .font(.headline)
                                .foregroundStyle(selected == day ? .lines : .gray)
                        }
                        .padding(.horizontal, 12)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke().frame(height: 35))
                        
                        .foregroundStyle(selected == day ? .lines : .lines.opacity(0.5))
                        
                        
                    }
                }.padding(.top, 20)
                    
                TabView(selection: $selected) {
                    ForEach(Sched.items[0].schedule.indices, id: \.self) { day in
                        VStack {DayView(daySched: Sched.items[0].schedule[day], pinSched: Sched.items[0].pinSchedule[day])
                                .environmentObject(settingsManager)
                        }
                            .tag(day)
                    }
                }.tabViewStyle(.page(indexDisplayMode: .never))
                

                
            }.tabItem { 
                Image(systemName: "book.pages.fill").imageScale(.large)}
            
            List {
                
                Toggle(isOn: $settingsManager.isEvenWeek, label: {
                    Text("Четная неделя")
                        .frame(alignment: .center)
                    Text("Оставьте выключенным, если у вас такого нет")
                        .foregroundStyle(.gray)
                        //.font(.caption)
                        .frame(width: 190)
                })
            }.tabItem { Image(systemName: "gear") }
        }.tabViewStyle(DefaultTabViewStyle())//.tabViewStyle()
        
    }
}

#Preview {
    ContentView()
}
