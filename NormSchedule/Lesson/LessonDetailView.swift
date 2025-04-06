//
//  DetailLessonView.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 03.04.2025.
//

import SwiftUI
import RichTextKit

struct LessonDetailView: View {
    @Binding var lesson: Lesson
    @Environment(\.presentationMode) var presentationMode
    @State private var editedNote = NSAttributedString()
    @State private var selectedParityType: Int = 0
    @State private var customParityName: String = ""
    @StateObject var context = RichTextContext()
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Основная информация")) {
                    TextEditor(text: $lesson.name)
                    TextEditor(text: $lesson.teacher)
                    TextEditor(text: $lesson.place)
                }
                
                Section(header: Text("Время")) {
                    DatePicker(
                        "Начало",
                        selection: Binding<Date>(
                            get: {
                                let baseDate = Calendar.current.startOfDay(for: Date())
                                return baseDate.addingTimeInterval(lesson.timeStart)
                            },
                            set: {
                                lesson.timeStart = $0.timeIntervalSince(Calendar.current.startOfDay(for: $0))
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                    DatePicker(
                        "Окончание",
                        selection: Binding<Date>(
                            get: {
                                let baseDate = Calendar.current.startOfDay(for: Date())
                                return baseDate.addingTimeInterval(lesson.timeEnd)
                            },
                            set: {
                                lesson.timeEnd = $0.timeIntervalSince(Calendar.current.startOfDay(for: $0))
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                }
                
                Section(header: Text("Детали")) {
                    TextField("Тип занятия", text: $lesson.type)
                    
                    TextField("Подгруппа", text: $lesson.subgroup)
                    
                }
                Section(header: Text("Четность недели")) {
                    Picker("Выберите тип", selection: $selectedParityType) {
                        Text("Всегда").tag(0)
                        Text("Только четные").tag(1)
                        Text("Только нечетные").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: selectedParityType) { updateParity() }
                    
                    if selectedParityType != 0 {
                        TextField("Название недели", text: $customParityName)
                            .onChange(of: customParityName) { updateParity() }
                    }
                }
                .onAppear { setupInitialValues() }
                
                Section(header: Text("Заметки")) {
                    RichTextEditor(text: $editedNote, context: context)
                    //                {
                    //                    $0.textContentInset = CGSize(width: 10, height: 30)
                    //                }
                        .focusedValue(\.richTextContext, context)
                        .frame(height: 200)
                }
            }
            .navigationTitle("Редактирование пары")
            .navigationBarItems(trailing: Button("Готово") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .onAppear {
            editedNote = lesson.note
        }
        .onDisappear {
            lesson.note = editedNote
        }

        .overlay {
            VStack {
                Spacer()
                RichTextKeyboardToolbar(
                    context: context,
                    leadingButtons: { $0 },
                    trailingButtons: { $0 },
                    formatSheet: { $0 }
                )
            }

        }
    }

    private func setupInitialValues() {
        if lesson.parity.keys.contains(true) {
            selectedParityType = 1
            customParityName = lesson.parity[true] ?? ""
        } else if lesson.parity.keys.contains(false) {
            selectedParityType = 2
            customParityName = lesson.parity[false] ?? ""
        } else {
            selectedParityType = 0
        }
    }

    private func updateParity() {
        switch selectedParityType {
        case 1:
            lesson.parity = [true: customParityName]
        case 2:
            lesson.parity = [false: customParityName]
        default:
            lesson.parity = [:]
        }
    }
}

#Preview {
    LessonDetailView(lesson: .constant(Lesson(timeStart: 30000/*Date(timeIntervalSince1970: 30000)*/, timeEnd: 30000/*Date(timeIntervalSince1970: 32000)*/, type: "пр.", subgroup: "Цифровая кафедра", parity: [true: "чет."], name: "Бюджетирование и финансовое планирование ИТ-проектов", teacher: "Голубева С. С.", place: "12 корпус ауд.424")))
}

