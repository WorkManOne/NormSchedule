//
//  LessonVisibilityManagementView.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 06.04.2025.
//

import SwiftUI

struct LessonVisibilityManagementView: View {
    @Binding var lessons: [Lesson]
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(lessons.enumerated()), id: \.offset) { index, lesson in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(lessons[index].name)
                                .font(.headline)
                            Text(lessons[index].subgroup)
                                .font(.caption)
                            Text(lessons[index].parity.values.first ?? "")
                                .font(.caption2)
                            Text(lessons[index].type)
                                .font(.caption2)
                            Text(lessons[index].place)
                                .font(.caption2)
                            Text(lessons[index].teacher)
                                .font(.caption2)
                        }
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { !lessons[index].isHidden },
                            set: { newValue in lessons[index].isHidden = !newValue }
                        ))
                    }
                }
                .onMove(perform: moveLesson)
            }
            .navigationTitle("Видимость и порядок")
            .navigationBarItems(trailing: Button("Готово") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    func moveLesson(from: IndexSet, to destination: Int) {
        lessons.move(fromOffsets: from, toOffset: destination)
        
    }
}



#Preview {
    LessonVisibilityManagementView(lessons: .constant([Lesson(timeStart: 0, timeEnd: 123, type: "", subgroup: "", parity: [:], name: "", teacher: "", place: "")]))
}
