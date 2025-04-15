//
//  LessonDetailView.swift
//  NormScheduleCompanion Watch App
//
//  Created by Кирилл Архипов on 12.04.2025.
//

import SwiftUI

struct LessonDetailView: View {
    let lesson: Lesson
    let isPinnedTrue: Bool
    let isPinnedFalse: Bool
    let isShown: Bool

    var body: some View {
        VStack (alignment: .center) {
            HStack (alignment: .center) {
                Text(lesson.timeString())
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


#Preview {
    LessonDetailView(lesson: Lesson(timeStart: 0, timeEnd: 2000, type: "sdas", subgroup: "asf", parity: [:], name: "name", teacher: "treacher", place: "gg"), isPinnedTrue: true, isPinnedFalse: true, isShown: true)
}
