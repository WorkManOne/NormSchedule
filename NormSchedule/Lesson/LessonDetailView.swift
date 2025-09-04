//
//  DetailLessonView.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 03.04.2025.
//

import SwiftUI
import RichTextKit

struct LessonDetailView: View {
    @Binding var originalLesson: Lesson
    @State private var lesson: Lesson
    @Environment(\.presentationMode) var presentationMode
    @State private var editedNote = NSAttributedString()
    @State private var selectedParityType: Int = 0
    @State private var selectedImportance: LessonImportance = .unspecified
    @State private var customParityName: String = ""
    @StateObject var context = RichTextContext()

    init(lesson: Binding<Lesson>) {
        self._originalLesson = lesson
        self._lesson = State(initialValue: lesson.wrappedValue)
        self.editedNote = lesson.wrappedValue.note
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Основная информация")) {
                    TextField("Название", text: $lesson.name, axis: .vertical)
                    TextField("Преподаватель", text: $lesson.teacher, axis: .vertical)
                    TextField("Место", text: $lesson.place, axis: .vertical)
                }
                Section(header: Text("Важность")) {
                    Picker("Выберите важность", selection: $lesson.importance) {
                        ForEach (LessonImportance.allCases, id: \.self) { importance in
                            HStack {
                                if let icon = importance.icon {
                                    icon
                                        .foregroundStyle(importance.iconColor)
                                }
                                Text(importance.description)
                            }
                            .tag(importance)
                        }
                    }
                    .pickerStyle(.menu)
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        lesson.note = editedNote
                        originalLesson = lesson
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .onAppear {
            setupInitialValues()
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

