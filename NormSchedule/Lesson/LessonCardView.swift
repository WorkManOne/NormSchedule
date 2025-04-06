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
    let index : Int
    let pinned : [Bool : Int]

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
                    HStack (alignment: .center) {
                        Text(lesson.subgroup)
                        Spacer()
                        Text("\(lesson.timeString())")
                        Spacer()
                        Text(lesson.type)
                        ZStack {
                            Image(systemName: "pin.fill")
                                .foregroundStyle(.blue)
                                .opacity(index == pinned[true] ? 0.75 : 0)
                            Image(systemName: "pin.fill")
                                .foregroundStyle(.red)
                                .opacity(index == pinned[false] ? 0.75 : 0)
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
                    HStack (alignment: .center) {
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
        .frame(height: allHidden ? 50 : 180)
    }
}

#Preview {
    LessonCardView(lesson: Lesson(timeStart: 0, timeEnd: 12000, type: "", subgroup: "", parity: [:], name: "", teacher: "", place: ""), allHidden: false, index: 0, pinned: [false:0])
}
