//
//  ContentView.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 14.03.2024.
//
import SwiftData
import SwiftUI


struct ContentView: View {
    
    @AppStorage("selectedSchedule") private var selectedSchedule = -1
    
    @Environment(\.modelContext) var modelContext
    @Query var schedules : [GroupSched]
    
    @ObservedObject var settingsManager = SettingsManager()
    
    let universities = [("Не выбрано", 0), ("СГУ", 1), ("СГТУ", 2)]
    //let badInitSchedule =
    @State private var parity = "Нет"
    let parityNames = ["Нет", "Чет", "Нечет"]
    @State private var dayTabBarPosition = "Сверху"
    let positionNames = ["Сверху", "Cнизу"]

    @State private var isLoadingFaculties = false
    @State private var isLoadingGroups = false
    @State private var isLoadingSchedule = false
    @State private var isLoadingTeachers = false
    
    @State private var Faculties : [Faculty] = []
    @State private var Groups: [Group] = []
    @State private var Teachers : [Teacher] = []

    @State private var selectedUniversity : (String, Int) = ("Не выбрано", 0)
    @State private var selectedFaculty : Faculty = Faculty(name: "undefined", uri: "undefined")
    @State private var selectedGroup : Group = Group(name: "undefined", uri: "undefined") {
        didSet {
            print(selectedGroup)
        }
    }
    @State private var selectedTeacher : Teacher = Teacher(name: "undefined", uri: "undefined")
    
    var body: some View {
        TabView {
            
            ScheduleView(groupSchedule: selectedSchedule < 0 || selectedSchedule >= schedules.count ? GroupSched(university: "", faculty: "", group: "badInit", date_read: "", schedule: [], pinSchedule: []) : schedules[selectedSchedule])
                        .environmentObject(settingsManager)
                        .tabItem { Image(systemName: "book.pages.fill").imageScale(.large) }
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
                            settingsManager.isEvenWeek = parityNames.firstIndex(of: parity) ?? 0
                        }
                        Picker(selection: $dayTabBarPosition, label: Text("Позиция дней недели")) {
                            ForEach(positionNames, id: \.self) { name in
                                Text(name)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: dayTabBarPosition) {
                            settingsManager.dayTabBarPosition = dayTabBarPosition == "Сверху"
                        }
                    }
                    Section ("Отображаемое расписание") {
                        DisclosureGroup("Выбранное расписание:") {
                            ForEach (schedules) {schedule in
                                Button {
                                    selectedSchedule = schedules.firstIndex(of: schedule) ?? -1
                                    print(selectedSchedule)
                                } label: {
                                    HStack {
                                        VStack (alignment: .leading) {
                                            Text(schedule.university)
                                            Text(schedule.faculty)
                                            Text(schedule.group)
                                            Text(schedule.date_read)
                                                .font(.footnote)
                                            
                                        }
                                        Spacer()
                                        Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(.green)
                                                .opacity( selectedSchedule >= 0 && selectedSchedule < schedules.count && schedule == schedules[selectedSchedule] ? 1 : 0)
                                    }
                                }
                            }.onDelete(perform: deleteSchedules)
                        }
                        Button(action: {
                            schedules.forEach { schedule in
                                modelContext.delete(schedule)
                            }
                            selectedSchedule = -1
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
                            Groups.removeAll()
                            Faculties.removeAll()
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
                                isLoadingSchedule = true
                                getGroup(id: selectedUniversity.1, uri: selectedGroup.uri) { schedule in
                                    modelContext.insert(schedule)
                                    isLoadingSchedule = false
//                                    let fetchDescriptor = FetchDescriptor<GroupSched>()
//                                    if let fetchedSchedules = try? modelContext.fetch(fetchDescriptor) {
//                                        selectedSchedule = fetchedSchedules.count - 1
//                                    }
                                }
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
                                isLoadingSchedule = true
                                getGroup(id: selectedUniversity.1, uri: selectedTeacher.uri) { schedule in
                                    modelContext.insert(schedule)
                                    isLoadingSchedule = false
//                                    let fetchDescriptor = FetchDescriptor<GroupSched>()
//                                    if let fetchedSchedules = try? modelContext.fetch(fetchDescriptor) {
//                                        selectedSchedule = fetchedSchedules.count - 1
//                                    }
                                }
                                
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
                parity = parityNames[settingsManager.isEvenWeek]
                dayTabBarPosition = positionNames[settingsManager.dayTabBarPosition ? 0 : 1]
            }
            .tabItem { Image(systemName: "gear") }
        }
        //.tabViewStyle(DefaultTabViewStyle())//.tabViewStyle()
        
    }
    func deleteSchedules(_ indexSet: IndexSet) {
        for index in indexSet {
            let schedule = schedules[index]
            modelContext.delete(schedule)
        }
    }
}

#Preview {
    ContentView()
}
