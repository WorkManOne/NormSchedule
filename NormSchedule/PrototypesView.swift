////
////  SwiftUIView.swift
////  NormSchedule
////
////  Created by Кирилл Архипов on 13.04.2024.
////
//
//import SwiftUI
//
//struct GroupSched2 {
////    init(university: String, faculty: String, group: String, date_read: String, schedule: [String : [[Lesson]]], pinSchedule: [[Int]], id: UUID? = nil) {
////        self.university = university
////        self.faculty = faculty
////        self.group = group
////        self.id = UUID(uuidString: "\(university)\(faculty)\(group)") ?? UUID()
////        self.schedule = schedule
////        self.pinSchedule = pinSchedule
////        self.date_read = date_read
////    }
//    var university : String
//    var faculty : String
//    var group : String
//    var date_read : String
//    var schedule : [String : [[Lesson]]]
//    //    var pinSchedule : [[Int]] =   [ [0,0,0,2,0,0,0,0,0], [1,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0] ]
//    var pinSchedule : [String:[Int]]
//    //var id = UUID()
//}
//
//struct PrototypesView: View { //Ах, если бы можно было упорядочить дни и изменять словарь
//    let days = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
//    let parityNames = ["Чет", "Нечет", "Нет"]
//    @State private var parity = "Нет"
//    
//    @State private var selected = "Вт"
//    
//    @ObservedObject var settingsManager = SettingsManager()
//    @State private var sched = GroupSched2(university: "bomba",
//                                   faculty: "2",
//                                   group: "311",
//                                   date_read: "67",
//                                   schedule: ["Пн": [[Lesson(timeStart: "08:20", timeEnd: "09:50", type: "пр.", subgroup: "Цифровая кафедра", parity: [true: "чис."], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424"), Lesson(timeStart: "08:20", timeEnd: "09:50", type: "пр.", subgroup: "АУЕ урок", parity: [true: "чис."], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424")]],
//                                              "Вт": [[Lesson(timeStart: "08:20", timeEnd: "09:50", type: "пр.", subgroup: "АААААААААА", parity: [true: "чис."], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424"), Lesson(timeStart: "08:20", timeEnd: "09:50", type: "пр.", subgroup: "АУЕ урок", parity: [true: "чис."], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424")]],
//                                              "Ср": [[Lesson(timeStart: "08:20", timeEnd: "09:50", type: "пр.", subgroup: "ББББББББББББ", parity: [true: "чис."], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424"), Lesson(timeStart: "08:20", timeEnd: "09:50", type: "пр.", subgroup: "АУЕ урок", parity: [true: "чис."], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424")]]],
//                                    pinSchedule: [ "Пн" : [0,0,0,0,0,0,0,0,0], "Вт" : [0,0,0,0,0,0,0,0,0], "Ср":[0,0,0,0,0,0,0,0,0], "Чт":[0,0,0,0,0,0,0,0,0], "Пт":[0,0,0,0,0,0,0,0,0], "Сб":[0,0,0,0,0,0,0,0,0], "Вс":[0,0,0,0,0,0,0,0,0] ])
//    
//    init() {
//        UIPageControl.appearance().currentPageIndicatorTintColor = .blue
//        UIPageControl.appearance().pageIndicatorTintColor = .lines
//        UIPageControl.appearance().tintColor = .lines
//        //self._selected = State(wrappedValue: Sched.currDay)
//    }
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
//                        .foregroundStyle(selected == day ? .lines : .lines.opacity(0.5))
//                    }
//                }.padding(.top, 20)
//                Spacer()
//                TabView(selection: $selected) {
//                    ForEach(sched.schedule.keys.sorted(), id: \.self) { day in
//                        DayView(daySched: sched.schedule[day]!, pinSched: .constant([0,0,0,0,0]))
//                            .environmentObject(settingsManager)
//                            .tag(day)
//                    }
//                }
////                    .onChange(of: Sched.currDay) {
////                        selected = Sched.currDay
////                    }
//                    .tabViewStyle(.page(indexDisplayMode: .never))
//            }.tabItem { Image(systemName: "book.pages.fill").imageScale(.large) }
//            
//        }
//        //.tabViewStyle(DefaultTabViewStyle())//.tabViewStyle()
//        
//    }
//}
//
//#Preview {
//    PrototypesView()
//}
