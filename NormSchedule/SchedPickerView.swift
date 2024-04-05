//
//  SchedPickerView.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 31.03.2024.
//

import SwiftUI

struct SchedPickerView: View {
    @ObservedObject var Sched = SchedModel() //TODO: СОЗДАЕТ БАГИ С ПОСТОЯННОЙ РЕФОРМАЦИЕЙ ПИНОВ!
    @State private var isLoading = false
    @State private var Groups : [Group] = []
    @State private var Teachers : [Teacher] = []
    @State private var selectedGroup : Group = Group(number: "", uri: "", facultyName: "")
    @State private var selectedTeacher : Teacher = Teacher(name: "", uri: "")
    @State private var searchTextGroups = ""
    private var filteredGroups : [Group] {
        guard !searchTextGroups.isEmpty else { return Groups }
        return Groups.filter { ("\($0.number) \($0.facultyName) ").localizedCaseInsensitiveContains(searchTextGroups) }
    }
    
    @State private var searchTextTeacher = ""
    private var filteredTeachers : [Teacher] {
        guard !searchTextTeacher.isEmpty else { return Teachers }
        return Teachers.filter { ("\($0.name)").localizedCaseInsensitiveContains(searchTextTeacher) }
    }

    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text("Скачать расписание")
                Button(action: {
                    isLoading = true
                    getFacultGroups { fac in
                        DispatchQueue.main.async {
                            self.Groups = fac
                            isLoading = false
                        }
                    }
                }) {
                    Text("Загрузить факультеты и группы")
                        .foregroundStyle(.white)
                }.padding().background(.gray)
                
                Button(action: {
                    isLoading = true
                    getTeachers { teacher in
                        DispatchQueue.main.async {
                            self.Teachers = teacher
                            isLoading = false
                        }
                    }
                }) {
                    Text("Загрузить преподавателей")
                        .foregroundStyle(.white)
                }.padding().background(.gray)
                
                Button(action: {
                    Sched.clearData()
                }) {
                    Text("Очистить расписание")
                        .foregroundStyle(.white)
                }.padding().background(.gray)
                if !Groups.isEmpty {
                    Picker(selection: $selectedGroup.uri, label: Text("Выберите группу").foregroundStyle(.white)) {
                        ForEach(filteredGroups, id: \.uri) { group in
                            Text("\(group.number) \(group.facultyName)").tag(group.uri)
                                .searchable(text: $searchTextGroups, placement: .sidebar, prompt: Text("Поиск группы") )
                                //.foregroundStyle(.white)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    .padding().background(.lines)
                } else if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(3)
                }
                else {
                    Text("Нет доступных факультетов и групп")
                }
                
                if !Teachers.isEmpty {
                    Picker(selection: $selectedTeacher.uri, label: Text("Выберите преподавтеля").foregroundStyle(.white)) {
                        ForEach(filteredTeachers, id: \.uri) { teacher in
                            Text("\(teacher.name)").tag(teacher.uri)
                                .searchable(text: $searchTextTeacher, placement: .sidebar, prompt: Text("Поиск группы") )
                                //.foregroundStyle(.white)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    .padding().background(.lines)
                } else if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(3)
                }
                else {
                    Text("Нет доступных преподавателей")
                }
                
                Button(action: {
                    if (!Groups.isEmpty) {
                        print(selectedGroup.uri)
                        Sched.getData(uri: selectedGroup.uri)
                    }
                }) {
                    Text("Загрузить выбранное расписание")
                        .foregroundStyle(.white)
                }.padding().background(.gray)
                Button(action: {
                    if (!Teachers.isEmpty) {
                        print(selectedTeacher.uri)
                        Sched.getData(uri: selectedTeacher.uri)
                    }
                }) {
                    Text("Загрузить выбранное расписание преподавателя")
                        .foregroundStyle(.white)
                }.padding().background(.gray)
                
                Picker(selection: $Sched.currItem, label: Text("Выберите расписание").foregroundStyle(.white)) {
                    ForEach(Sched.items.indices, id: \.self) { index in
                        HStack {
                            Text("\(Sched.items[index].faculty) \(Sched.items[index].group)")
                                
                        }
                    }
                }
                .pickerStyle(.navigationLink)
                .padding().background(.lines)
                

                              
            }.padding(40)
        }
    }
}

#Preview {
    SchedPickerView()
}
