//
//  LessonCardView.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 06.04.2025.
//

import SwiftUI

struct LessonCardView: View {
    let lesson : Lesson
    let allHidden : Bool
    let pinned : [Bool : UUID]

    var body: some View {
        ZStack {
            HStack {
                Spacer()
            }
            RoundedRectangle(cornerRadius: 25)
                    .fill(Color("frameColor"))
                    .overlay(alignment: .topTrailing) {
                        if !lesson.note.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Path { path in
                                path.move(to: CGPoint(x: 0, y: 0))
                                path.addLine(to: CGPoint(x: 35, y: 35))
                                path.addLine(to: CGPoint(x: 35, y: 0))
                                path.closeSubpath()
                            }
                            .fill(Color.yellow)
                            .frame(width: 35, height: 35)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .shadow(color: .gray.opacity(0.5), radius: 2)

            if !allHidden {
                VStack (alignment: .center) {
                    HStack (alignment: .top) {
                        Text(lesson.subgroup)
                        if let icon = lesson.importance.icon {
                            icon
                                .foregroundStyle(lesson.importance.iconColor)
                                .help(lesson.importance.description)
                        }
                        Spacer()
                        Text("\(lesson.timeString())")
                        Spacer()
                        Text(lesson.type)
                        ZStack {
                            Image(systemName: "pin.fill")
                                .foregroundStyle(.blue)
                                .opacity(lesson.id == pinned[true] ? 0.75 : 0)
                            Image(systemName: "pin.fill")
                                .foregroundStyle(.red)
                                .opacity(lesson.id == pinned[false] ? 0.75 : 0)
                        }
                    }
                    Spacer()
                    HStack (alignment: .center) {
                        Text(lesson.name)
                            .fontWeight(.bold)
                            .padding(5)
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                    HStack (alignment: .bottom) {
                        Text(lesson.teacher)
                        Spacer()
                        if !lesson.parity.isEmpty {
                            if let firstParity = lesson.parity.first {
                                Text(firstParity.value)
                                    .foregroundColor(.red)
                            }
                            else { Text("") }
                        }
                        else { Text("") }
                        Spacer()
                        Text(lesson.place)
                    }
                }
                .padding(.bottom)
                .padding()
            } else {
                HStack (alignment: .center) {
                    Spacer()
                    Text("\(lesson.timeString())")
                    Spacer()
                }
            }
        }
        .frame(width: min(360, UIScreen.main.bounds.width * 0.9), height: allHidden ? 50 : 180)
    }
}

#Preview {
    LessonCardView(lesson: Lesson(timeStart: 0, timeEnd: 12000, type: "", subgroup: "", parity: [:], name: "", teacher: "", place: ""), allHidden: false, pinned: [Bool: UUID]())
}
