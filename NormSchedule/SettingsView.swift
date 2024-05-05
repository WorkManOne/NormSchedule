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
    let universities = [("Не выбрано", 0), ("СГУ", 1), ("СГТУ", 2)]
    //@Binding var Sched : SchedModel
//    @ObservedObject var Sched = SchedModel() //TODO: СОЗДАЕТ БАГИ С ПОСТОЯННОЙ РЕФОРМАЦИЕЙ ПИНОВ!
//    @State var isEvenWeek = 0
    
    @ObservedObject var Sched : SchedModel //TODO: СОЗДАЕТ БАГИ С ПОСТОЯННОЙ РЕФОРМАЦИЕЙ ПИНОВ!
    
    @Binding var isEvenWeek : Int
    @State private var parity = "Нет"
    let parityNames = ["Нет", "Чет", "Нечет"]
    
    @State private var isLoadingFaculties = false
    @State private var isLoadingGroups = false
    @State private var isLoadingSchedule = false
    @State private var isLoadingTeachers = false
    
    @State private var Faculties : [Faculty] = []
    @State private var Groups : [Group] = []
    @State private var Teachers : [Teacher] = []
    
    @State private var selectedUniversity : (String, Int) = ("Не выбрано", 0)
    @State private var selectedFaculty : Faculty = Faculty(name: "undefined", uri: "undefined")
    @State private var selectedGroup : Group = Group(name: "undefined", uri: "undefined")
    @State private var selectedTeacher : Teacher = Teacher(name: "undefined", uri: "undefined")
    
//    @State private var searchTextGroups = ""
//    private var filteredGroups : [Group] {
//        guard !searchTextGroups.isEmpty else { return Groups }
//        return Groups.filter { group in
//            let search = searchTextGroups.lowercased()
//            return group.name.lowercased().contains(search) }
//    }
//    @State private var searchTextTeacher = ""
//    private var filteredTeachers : [Teacher] {
//        guard !searchTextTeacher.isEmpty else { return Teachers }
//        return Teachers.filter { teacher in
//            let search = searchTextTeacher.lowercased()
//            return teacher.name.lowercased().contains(search) }
//    }

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
                        //Sched.pinnedReform()
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
                
                Section ("Загрузить расписание") {
                    Button(action: {
                        isLoadingFaculties = true
                        getFacultiesUri (id: selectedUniversity.1) { facs in
                            DispatchQueue.main.async {
                                self.Faculties = facs
                                isLoadingFaculties = false
                            }
                        }
                    }) {
                        Text("Обновить списки")
                    }
                    Picker(selection: $selectedUniversity.1, label: Text("Университет")) {
                        ForEach(universities, id: \.1) { uni in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("\(uni.0)")
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .tag(uni.1)
                            }
                        }
                    }
                    .pickerStyle(.navigationLink)
                    .onChange(of: selectedUniversity.1) {
                        isLoadingFaculties = true
                        getFacultiesUri (id: selectedUniversity.1) { facs in
                            DispatchQueue.main.async {
                                self.Faculties = facs
                                isLoadingFaculties = false
                            }
                        }
                    }
                    
                    if isLoadingFaculties {
                        HStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(.circular)
                                .scaledToFill()
                            Spacer()
                        }
                    }
                    else if !Faculties.isEmpty {
                        Picker(selection: $selectedFaculty.uri, label: Text("Факультет")) {
                            Text("Не выбрано").tag("undefined")
                            ForEach(Faculties, id: \.uri) { faculty in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("\(faculty.name)")
                                        Text("\(faculty.uri)")
                                            .foregroundStyle(.gray)
                                            .font(.footnote)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .tag(faculty.uri)
                                }
                            }
                        }
                        .pickerStyle(.navigationLink)
                        .onChange(of: selectedFaculty.uri) {
                            isLoadingGroups = true
                            getGroupsUri (id: selectedUniversity.1, uri: selectedFaculty.uri) { groups in
                                DispatchQueue.main.async {
                                    self.Groups = groups
                                    isLoadingGroups = false
                                }
                            }
                        }
                    }
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
                            Picker(selection: $selectedGroup.uri, label: Text("Группа")) {
                                Text("Не выбрано").tag("undefined")
                                ForEach(Groups, id: \.uri) { group in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("\(group.name)")
                                            Text("\(group.uri)")
                                                .foregroundStyle(.gray)
                                                .font(.footnote)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .tag(group.uri)
                                    }
                                }
                            }
                            .pickerStyle(.navigationLink)
                        
                        
                    }
                    
                    Button(action: {
                        if (!Groups.isEmpty) {
                            print(selectedGroup.uri)
                            Sched.getData(id: selectedUniversity.1, uri: selectedGroup.uri)
                            isLoadingSchedule = true
                        }
                    }) {
                        if isLoadingSchedule {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .scaledToFill()
                                Spacer()
                            }
                        }
                        else {
                            Text("Загрузить выбранное расписание")
                        }
                    }
                    
                    Button(action: {
                        isLoadingTeachers = true
                        getTeachersUri (id: selectedUniversity.1) { teachers in
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
                        Picker(selection: $selectedTeacher.uri, label: Text("Преподаватель")) {
                            Text("Не выбрано").tag("undefined")
                            ForEach(/*filtered*/Teachers, id: \.uri) { teacher in
                                Text("\(teacher.name)").tag(teacher.uri)
                                    //.searchable(text: $searchTextTeacher, placement: .sidebar, prompt: Text("Поиск группы") )
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
                            Sched.getData(id: selectedUniversity.1, uri: selectedTeacher.uri)
                            isLoadingSchedule = true
                        }
                    }) {
                        if isLoadingSchedule {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .scaledToFill()
                                Spacer()
                            }
                        }
                        else {
                            Text("Загрузить выбранное расписание преподавателя")
                        }
                    }
                    
                }
            }
        }
        .onAppear {
            parity = parityNames[isEvenWeek]
        }
        .onChange(of: Sched.currItem) { //TODO: плохо потому что если не поменяется курсор но расписание будет только одно, то реформа не произойдет, также зависнет загрузка
            Sched.pinnedReform()
            isLoadingSchedule = false
        }
    }
}

//#Preview {
//    SettingsView()
//}
