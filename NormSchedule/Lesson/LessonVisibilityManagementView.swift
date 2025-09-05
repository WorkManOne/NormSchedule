//
//  LessonVisibilityManagementView.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 06.04.2025.
//

import SwiftUI

struct LessonVisibilityManagementView: View {
    @Binding var originalLessons: [Lesson]
    @State var lessons: [Lesson]
    @Environment(\.dismiss) var dismiss

    init(lessons: Binding<[Lesson]>) {
        self._originalLessons = lessons
        self._lessons = State(initialValue: lessons.wrappedValue)
    }

    var body: some View {
        NavigationStack {
            VStack {
                Section {
                    Text("Удерживайте и перетаскивайте пару, чтобы изменить порядок. Переключайте тумблеры, чтобы установить видимость пары.")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                    List {
                        ForEach(Array(lessons.enumerated()), id: \.element.id) { index, lesson in
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
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Видимость и порядок")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        dismiss()

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { // TODO: Костыль позволяющий избегать бага с анимацией (для воспроизведения нужно скрыть пару 2, сохранить, открыть раскрыть переместить на первое место или попробовать другие варианты воспроизведения бага, итог: блок занятия исчезает, если не юзать Dispatch)
                            withAnimation {
                                originalLessons = lessons
                            }
                        }

                    }
                }
            }
        }
    }

    func moveLesson(from: IndexSet, to destination: Int) {
        lessons.move(fromOffsets: from, toOffset: destination)
    }
}



#Preview {
    LessonVisibilityManagementView(lessons: .constant([Lesson(timeStart: 0, timeEnd: 123, type: "", subgroup: "", parity: [:], name: "", teacher: "", place: "")]))
}
