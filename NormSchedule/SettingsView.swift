//
//  SchedPickerView.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 31.03.2024.
//

import SwiftUI

struct FindView <T>: View {
    @Binding var selected : T
    @Binding var list : [T]
    
    @State private var searchText = ""
    private var filtered : [T] {
        guard !searchText.isEmpty else { return list }
        return list.filter { _ in ("").localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        Text("hh")
    }
}

struct SettingsView: View {
    
    //@Binding var Sched : SchedModel
    //@ObservedObject var Sched = SchedModel() //TODO: СОЗДАЕТ БАГИ С ПОСТОЯННОЙ РЕФОРМАЦИЕЙ ПИНОВ!
    //@State var isEvenWeek = 0
    
    @ObservedObject var Sched : SchedModel //TODO: СОЗДАЕТ БАГИ С ПОСТОЯННОЙ РЕФОРМАЦИЕЙ ПИНОВ!
    @Binding var isEvenWeek : Int
    
    let parityNames = ["Нет", "Чет", "Нечет"]
    @State private var parity = "Нет"
    @State private var isLoadingGroups = false
    @State private var isLoadingTeachers = false
    @State private var Groups : [Group] = []
    @State private var Teachers : [Teacher] = []
    @State private var selectedGroup : Group = Group(number: "", uri: "", facultyName: "")
    @State private var selectedTeacher : Teacher = Teacher(name: "", uri: "")
    @State private var searchTextGroups = ""
    private var filteredGroups : [Group] {
        guard !searchTextGroups.isEmpty else { return Groups }
        return Groups.filter { group in
            let search = searchTextGroups.lowercased()
            return group.facultyName.lowercased().contains(search) || group.number.lowercased().contains(search) }
    }
    @State private var searchTextTeacher = ""
    private var filteredTeachers : [Teacher] {
        guard !searchTextTeacher.isEmpty else { return Teachers }
        return Teachers.filter { teacher in
            let search = searchTextTeacher.lowercased()
            return teacher.name.lowercased().contains(search) }
    }

    var body: some View {
        NavigationStack {
            List {
                Section ("Настройки") {
                    Picker(selection: $parity, label: Text("Четность недели")) {
                        ForEach(parityNames, id: \.self) { name in
                            Text(name)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: parity) {
                        isEvenWeek = parityNames.firstIndex(of: parity) ?? 0
                        Sched.pinnedReform()
                    }
                    
                }
                
                Section ("Отображаемое расписание") {
                    Picker(selection: $Sched.currItem, label: Text("Расписание")) {
                        ForEach(Sched.items.indices, id: \.self) { index in
                            HStack {
                                Text("\(Sched.items[index].faculty) \(Sched.items[index].group)")
                                
                            }
                        }
                    }
                    .pickerStyle(.navigationLink)
                    Button(action: {
                        Sched.clearData()
                    }) {
                        Text("Очистить всё расписание")
                    }
                }
                
                Section ("Группы") {
                    Button(action: {
                        isLoadingGroups = true
                        getFacultGroups { groups in
                            DispatchQueue.main.async {
                                self.Groups = groups
                                isLoadingGroups = false
                            }
                        }
                    }) {
                        Text("Обновить факультеты")
                        //.foregroundStyle(.white)
                    }//.padding().background(.gray)
                    
                    
                    if isLoadingGroups {
                        HStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(.circular)
                                .scaledToFill()
                            Spacer()
                        }
                    }
                    else if !Groups.isEmpty {
                        Picker(selection: $selectedGroup.uri, label: Text("Выберите группу")) {
                            ForEach(filteredGroups, id: \.uri) { group in
                                Text("\(group.number) \(group.facultyName)").tag(group.uri)
                                    .searchable(text: $searchTextGroups, placement: .sidebar, prompt: Text("Поиск группы") )
                                //.foregroundStyle(.white)
                            }
                        }
                        .pickerStyle(.navigationLink)
                    }
                    else {
                        Text("Нет доступных факультетов")
                    }
                    
                    Button(action: {
                        if (!Groups.isEmpty) {
                            print(selectedGroup.uri)
                            Sched.getData(uri: selectedGroup.uri)
                        }
                    }) {
                        Text("Загрузить выбранное расписание")
                    }
                }
                
                Section ("Преподаватели") {
                    Button(action: {
                        isLoadingTeachers = true
                        getTeachers { teachers in
                            DispatchQueue.main.async {
                                self.Teachers = teachers
                                isLoadingTeachers = false
                            }
                        }
                    }) {
                        Text("Обновить преподавателей")
                    }
                    
                    if isLoadingTeachers {
                        HStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(.circular)
                                .scaledToFill()
                            Spacer()
                        }
                        
                    }
                    else if !Teachers.isEmpty {
                        Picker(selection: $selectedTeacher.uri, label: Text("Выберите преподавателя")) {
                            ForEach(filteredTeachers, id: \.uri) { teacher in
                                Text("\(teacher.name)").tag(teacher.uri)
                                    .searchable(text: $searchTextTeacher, placement: .sidebar, prompt: Text("Поиск группы") )
                                //.foregroundStyle(.white)
                            }
                        }
                        .pickerStyle(.navigationLink)
                    }
                    else {
                        Text("Нет доступных преподавателей")
                    }
                    Button(action: {
                        if (!Teachers.isEmpty) {
                            print(selectedTeacher.uri)
                            Sched.getData(uri: selectedTeacher.uri)
                        }
                    }) {
                        Text("Загрузить выбранное расписание преподавателя")
                    }
                }
                
                
            }
        }
    }
}

//#Preview {
//    SettingsView()
//}
