//
//  SearchableSchedulePickerView.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 03.09.2025.
//

import SwiftUI

struct SearchableSchedulePickerView: View {
    let title: String
    @Binding var selection: GroupSched?
    let items: [GroupSched]
    let onSelect: (GroupSched) -> Void
    let onDelete: (GroupSched) -> Void
    let onEdit: (GroupSched) -> Void
    let onCreate: () -> Void

    @Environment(\.dismiss) var dismiss

    @State private var searchText = ""
    @State private var showingEditSheet = false
    @State private var editingSchedule: GroupSched?

    init(title: String,
         selection: Binding<GroupSched?>,
         items: [GroupSched],
         onSelect: @escaping (GroupSched) -> Void,
         onDelete: @escaping (GroupSched) -> Void,
         onEdit: @escaping (GroupSched) -> Void,
         onCreate: @escaping () -> Void
    ) {
        self.title = title
        self._selection = selection
        self.items = items
        self.onSelect = onSelect
        self.onDelete = onDelete
        self.onEdit = onEdit
        self.onCreate = onCreate
    }

    var filteredItems: [GroupSched] {
        guard !searchText.isEmpty else { return items }
        return items.filter { schedule in
            schedule.university.localizedCaseInsensitiveContains(searchText) ||
            schedule.faculty.localizedCaseInsensitiveContains(searchText) ||
            schedule.group.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack (spacing: 0) {
            TextField("Поиск по университету, факультету или группе...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            if filteredItems.isEmpty {
                Spacer()
                Text("Расписания не найдены")
                    .foregroundColor(.secondary)
                    .font(.title2)
                Spacer()
            } else {
                List {
                    ForEach(filteredItems, id: \.id) { schedule in
                        Button {
                            selection = schedule
                            onSelect(schedule)
                            dismiss()
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(schedule.group)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text(schedule.university)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    if !schedule.faculty.isEmpty {
                                        Text(schedule.faculty)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    if !schedule.date_read.isEmpty {
                                        Text("Загружено: \(schedule.date_read)")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()

                                if selection?.id == schedule.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                        .padding(.trailing, 8)
                                }

                                HStack(spacing: 8) {
                                    Button {
                                        editingSchedule = schedule
                                        showingEditSheet = true
                                    } label: {
                                        Image(systemName: "pencil")
                                            .foregroundColor(.blue)
                                            .frame(width: 44, height: 44)
                                            .padding(5)
                                            .background {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(.frame)
                                            }
                                    }

                                    Button {
                                        withAnimation {
                                            onDelete(schedule)
                                        }
                                    } label: {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                            .frame(width: 44, height: 44)
                                            .padding(5)
                                            .background {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(.frame)
                                            }
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    withAnimation {
                        onCreate()
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            if let schedule = editingSchedule {
                ScheduleEditView(schedule: schedule) { updatedSchedule in
                    onEdit(updatedSchedule)
                    showingEditSheet = false
                    editingSchedule = nil
                }
            }
        }
    }
}

struct ScheduleEditView: View {
    @State private var university: String
    @State private var faculty: String
    @State private var group: String

    let originalSchedule: GroupSched
    let onSave: (GroupSched) -> Void

    @Environment(\.presentationMode) var presentationMode

    init(schedule: GroupSched, onSave: @escaping (GroupSched) -> Void) {
        self.originalSchedule = schedule
        self.onSave = onSave
        self._university = State(initialValue: schedule.university)
        self._faculty = State(initialValue: schedule.faculty)
        self._group = State(initialValue: schedule.group)
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Основная информация") {
                    TextField("Университет", text: $university, axis: .vertical)
                    TextField("Факультет", text: $faculty, axis: .vertical)
                    TextField("Группа", text: $group, axis: .vertical)
                }

                Section("Дополнительная информация") {
                    if !originalSchedule.date_read.isEmpty {
                        HStack {
                            Text("Загружено:")
                            Spacer()
                            Text(originalSchedule.date_read)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                to: nil, from: nil, for: nil)
            }
            .navigationTitle("Редактировать расписание")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        let updatedSchedule = GroupSched(
                            university: university,
                            faculty: faculty,
                            group: group,
                            date_read: originalSchedule.date_read,
                            schedule: originalSchedule.schedule,
                            pinSchedule: originalSchedule.pinSchedule,
                            id: originalSchedule.id
                        )
                        onSave(updatedSchedule)
                    }
                    .disabled(group.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

//#Preview {
//    SearchableSchedulePickerView()
//}
