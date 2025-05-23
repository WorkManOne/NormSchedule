//
//  LessonsPreviewView.swift
//  NormScheduleCompanion Watch App
//
//  Created by Кирилл Архипов on 12.04.2025.
//

import SwiftUI

struct LessonsPreviewView: View {
    let lesson: Lesson
    let isPinnedTrue: Bool
    let isPinnedFalse: Bool
    let isShown: Bool

    var body: some View {
        VStack (alignment: .center) {
            HStack (alignment: .center) {

                if let icon = lesson.importance.icon {
                    icon
                        .foregroundStyle(lesson.importance.iconColor)
                }
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
            .padding(.horizontal)
            .padding(.top)
            Spacer()
            HStack (alignment: .center) {
                if !lesson.note.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    RoundedRectangle(cornerRadius: 3)
                        .frame(width: 3)
                        .foregroundStyle(.yellow)
                }
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

#Preview {
    LessonsPreviewView(lesson: Lesson(timeStart: 0, timeEnd: 32000, type: "type", subgroup: "sub", parity: [:], name: "sdf", teacher: "teacher", place: "pplcae", importance: .high), isPinnedTrue: true, isPinnedFalse: true, isShown: true)
}
