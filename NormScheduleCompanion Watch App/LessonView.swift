//
//  LessonView.swift
//  NormScheduleCompanion Watch App
//
//  Created by Кирилл Архипов on 03.03.2025.
//

import Foundation
import SwiftUI

struct SingleLessonView: View {
    let lesson: Lesson
    let isPinnedTrue: Bool
    let isPinnedFalse: Bool
    let isShown: Bool

    var body: some View {
        VStack (alignment: .center) {
            HStack (alignment: .center) {
                Text("\(lesson.timeStart) - \(lesson.timeEnd)")
                    .font(.system(size: 12))
                Spacer()
                Text(lesson.type)
                    .font(.system(size: 12))
                ZStack {
                    Image(systemName: "pin.fill")
                        .foregroundStyle(.blue)
                        .opacity(isPinnedTrue ? 0.75 : 0)
                    Image(systemName: "pin.fill")
                        .foregroundStyle(.red)
                        .opacity(isPinnedFalse ? 0.75 : 0)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            Spacer()
            HStack (alignment: .center) {
                Text(lesson.name)
                    .fontWeight(.bold)
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)
            }
            Spacer()
            VStack {
                Text(lesson.place)
                    .font(.system(size: 12))
                    .multilineTextAlignment(.center)
                Text(lesson.teacher)
                    .font(.system(size: 12))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .opacity(isShown ? 1 : 0.4)
    }
}

struct DetailedLessonView: View {
    let lesson: Lesson
    let isPinnedTrue: Bool
    let isPinnedFalse: Bool
    let isShown: Bool
    
    var body: some View {
        VStack (alignment: .center) {
            HStack (alignment: .center) {
                Text("\(lesson.timeStart) - \(lesson.timeEnd)")
                    .font(.system(size: 12))
                Spacer()
                Text(lesson.type)
                    .font(.system(size: 12))
                ZStack {
                    Image(systemName: "pin.fill")
                        .foregroundStyle(.blue)
                        .opacity(isPinnedTrue ? 0.75 : 0)
                    Image(systemName: "pin.fill")
                        .foregroundStyle(.red)
                        .opacity(isPinnedFalse ? 0.75 : 0)
                }
            }
            Text(lesson.subgroup)
                .font(.system(size: 12))
            Spacer()
            HStack (alignment: .center) {
                Text(lesson.name)
                    .fontWeight(.bold)
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)
            }
            Spacer()
            Text(lesson.place)
                .font(.system(size: 12))
            Text(lesson.teacher)
                .font(.system(size: 12))
                .multilineTextAlignment(.center)
            if !lesson.parity.isEmpty {
                if let firstParity = lesson.parity.first {
                    Text(firstParity.value)
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                }
                else { Text("") }
            }
            else { Text("") }
        }
        .opacity(isShown ? 1 : 0.4)
    }
}

struct LessonView: View {
    var lessons : [Lesson]
    @EnvironmentObject var settingsManager: SettingsManager
    @Binding var pinned : [Bool:Int]
    @State private var active = 0
    @State private var isShowingDetail = false
    //@State var isShown = true
    
    //
    //
    //    init(lessons: [Lesson], pinned: Binding<[Bool:Int]>) {
    //        self.lessons = lessons
    //        self._pinned = pinned
    //        self._active = State(wrappedValue: 0)
    //    }
    
    var body: some View {
//        NavigationLink {
//
//        } label: {
        Button {
            isShowingDetail.toggle()
        } label: {
            SingleLessonView(lesson: lessons[active], isPinnedTrue: active == pinned[true], isPinnedFalse: active == pinned[false],
                             isShown: (lessons[active].parity.keys.contains(true) && settingsManager.isEvenWeek == 1 || lessons[active].parity.keys.contains(false) && settingsManager.isEvenWeek == 2 || lessons[active].parity.isEmpty || settingsManager.isEvenWeek == 0))
        }
        .sheet(isPresented: $isShowingDetail) {
            List { //ScrollView looks worse, ux better
                ForEach(Array(lessons.enumerated()), id: \.element.id) { index, lesson in
                    DetailedLessonView(lesson: lesson, isPinnedTrue: index == pinned[true], isPinnedFalse: index == pinned[false],
                                     isShown: (lesson.parity.keys.contains(true) && settingsManager.isEvenWeek == 1 || lesson.parity.keys.contains(false) && settingsManager.isEvenWeek == 2 || lesson.parity.isEmpty || settingsManager.isEvenWeek == 0))
                    .tag(index)
                }
            }
        }

//        }
        .onAppear {
            if (settingsManager.isEvenWeek == 2) {
                active = pinned[false] ?? 0
            }
            else {
                active = pinned[true] ?? 0
            }
        }
        //
        //        .onTapGesture(count: 2) {
        //            //print("tapped \(active)")
        //            if (lessons[active].parity.keys.contains(false)
        //                && !lessons.allSatisfy { l in l.parity.keys.contains(false) }) {
        //                pinned[false] = active
        //            }
        //            else if (lessons[active].parity.keys.contains(true)
        //                     && !lessons.allSatisfy { l in l.parity.keys.contains(true) }) {
        //                pinned[true] = active
        //            }
        //            else {
        //                pinned[true] = active
        //                pinned[false] = active
        //            }
        //
        //        }
        //        .onChange(of: pinned) {
        //            if (settingsManager.isEvenWeek == 2) {
        //                active = pinned[false] ?? 0
        //            }
        //            else {
        //                active = pinned[true] ?? 0
        //            }
        //        }
        //        .tabViewStyle(.page(indexDisplayMode: .automatic))
        
    }
}


#Preview {
    LessonView(lessons: [Lesson(timeStart: 30000/*Date(timeIntervalSince1970: 30000)*/, timeEnd: 32000/*Date(timeIntervalSince1970: 32000)*/, type: "пр.", subgroup: "Цифровая кафедра", parity: [true: "чет."], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424"),
                         Lesson(timeStart: 30000/*Date(timeIntervalSince1970: 30000)*/, timeEnd: 30000/*Date(timeIntervalSince1970: 32000)*/, type: "пр.", subgroup: "АУЕ урок", parity: [:], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424")], pinned: .constant([true:1, false:0]))
        .environmentObject(SettingsManager())
}
