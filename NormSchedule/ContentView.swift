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

    @AppStorage("selectedScheduleID") private var selectedScheduleID: String?
    var selectedScheduleO: GroupSched? {
        guard let idString = selectedScheduleID, let uuid = UUID(uuidString: idString) else { return nil }
        return schedules.first { $0.id == uuid }
    }

    @Environment(\.modelContext) var modelContext
    @Query var schedules : [GroupSched]

    @ObservedObject var provider = WCProvider.shared
    @ObservedObject var settingsManager = SettingsManager()
    
    let universities = [("Не выбрано", 0), ("СГУ", 1), ("СГТУ", 2)]
    @State private var parity = "Нет"
    let parityNames = ["Нет", "Чет", "Нечет"]
    @State private var dayTabBarPosition = "Сверху"
    let positionNames = ["Сверху", "Cнизу"]
    @State private var dayTabBarStyle = "Округлый"
    let styleNames = ["Округлый", "Прямой"]
    @State private var isLoadingFaculties = false
    @State private var isLoadingGroups = false
    @State private var isLoadingSchedule = false
    @State private var isLoadingTeachers = false

    @State private var cachedFaculties: [Int: [Faculty]] = [:]
    @State private var cachedTeachers: [Int: [Teacher]] = [:]
    @State private var cachedGroups: [String: [Group]] = [:]

    @State private var faculties : [Faculty] = []
    @State private var groups: [Group] = []
    @State private var teachers : [Teacher] = []

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
                NavigationLink("Выбрать", destination:
                    SearchablePickerView(
                        title: "Выберите расписание",
                        selection: Binding<GroupSched?>(
                            get: { selectedScheduleO },
                            set: { newValue in
                                selectedScheduleID = newValue?.id.uuidString
                            }
                        ),
                        items: schedules,
                        searchKeyPath: \.group
                    ) { item in
                        HStack {
                            Image(systemName: "leaf")
                            Text(item.university)
                            Text(item.faculty)
                            Text(item.group)
                        }
                    }
                )
                Form {
                    NavigationLink("Выбрать", destination:
                        SearchablePickerView(
                            title: "Выберите факультет",
                            selection: Binding(
                                get: { selectedFaculty as Faculty? },
                                set: { selectedFaculty = $0 as! Faculty }
                            ),
                            items: faculties,
                            searchKeyPath: \.name
                        ) { item in
                            HStack {
                                Image(systemName: "leaf")
                                Text(item.name)
                            }
                        }
                    )
                    NavigationLink("Выбрать", destination:
                        SearchablePickerView(
                            title: "Выберите группу",
                            selection: Binding(
                                get: { selectedGroup as Group? },
                                set: { selectedGroup = $0 as! Group }
                            ),
                            items: groups,
                            searchKeyPath: \.name
                        ) { item in
                            HStack {
                                Image(systemName: "leaf")
                                Text(item.name)
                            }
                        }
                    )
                    Section ("Настройки") {
                        Picker(selection: $parity, label: Text("Четность недели")) {
                            ForEach(parityNames, id: \.self) { name in
                                Text(name)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())

                        Picker(selection: $dayTabBarPosition, label: Text("Позиция дней недели")) {
                            ForEach(positionNames, id: \.self) { name in
                                Text(name)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        Picker(selection: $dayTabBarStyle, label: Text("Стиль панели с днями")) {
                            ForEach(styleNames, id: \.self) { name in
                                Text(name)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
//                    Section ("Отображаемое расписание") {
                    DisclosureGroup("Выбранное расписание:") {
                            ForEach (schedules) { schedule in
                                Button {
                                    selectedScheduleID = schedule.id.uuidString
                                    selectedSchedule = schedules.firstIndex(of: schedule) ?? -1
                                    provider.updateSchedule(schedule: schedule)
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
//                        Button(action: {
//                            schedules.forEach { schedule in
//                                modelContext.delete(schedule)
//                            }
//                            selectedSchedule = -1
//                        }) {
//                            Text("Очистить всё расписание")
//                        }
//                    }
                    Section ("Загрузить расписание") {
                        Button(action: {
                            cachedFaculties.removeAll()
                            cachedGroups.removeAll()
                            cachedTeachers.removeAll()
                        }) {
                            Text("Удалить кэшированные данные (факультеты, группы, преподаватели)")
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

                        if isLoadingFaculties {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .scaledToFill()
                                Spacer()
                            }
                        }
                        else if !faculties.isEmpty {
                            Picker(selection: $selectedFaculty.uri, label: Text("Факультет")) {
                                Text("Не выбрано").tag("undefined")
                                ForEach(faculties, id: \.uri) { faculty in
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
                        else if !groups.isEmpty {
                            Picker(selection: $selectedGroup.uri, label: Text("Группа")) {
                                Text("Не выбрано").tag("undefined")
                                ForEach(groups, id: \.uri) { group in
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
                            if (!groups.isEmpty) {
                                isLoadingSchedule = true
                                getGroup(id: selectedUniversity.1, uri: selectedGroup.uri) { schedule in
                                    DispatchQueue.main.async {
                                        modelContext.insert(schedule)
                                        isLoadingSchedule = false
                                        let fetchDescriptor = FetchDescriptor<GroupSched>()
                                        if let fetchedSchedules = try? modelContext.fetch(fetchDescriptor) {
                                            selectedSchedule = fetchedSchedules.count - 1
                                        }
                                    }
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
                                    self.teachers = teachers
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
                        else if !teachers.isEmpty {
                            Picker(selection: $selectedTeacher.uri, label: Text("Преподаватель")) {
                                Text("Не выбрано").tag("undefined")
                                ForEach(/*filtered*/teachers, id: \.uri) { teacher in
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
                            if (!teachers.isEmpty) {
                                isLoadingSchedule = true
                                getGroup(id: selectedUniversity.1, uri: selectedTeacher.uri) { schedule in
                                    DispatchQueue.main.async {
                                        modelContext.insert(schedule)
                                        isLoadingSchedule = false
                                        let fetchDescriptor = FetchDescriptor<GroupSched>()
                                        if let fetchedSchedules = try? modelContext.fetch(fetchDescriptor) {
                                            selectedSchedule = fetchedSchedules.count - 1
                                        }
                                    }

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
        //                        .onChange(of: schedules[selectedSchedule]) {  //TODO: Ебать справа пожалуйста остановите, а как сделать чтобы на изменение pinned обновленная версия передавалась на часы? + Отследить все пути которые ведут к изменению расписания groupSched, потому что в качестве костылей я насоздавал слишком много всяких триггеров onChange - плохая практика, вообще везде надо глянуть onChange, код связанный с логикой и данными должен быть в коде а не в ui
        //                            print("update from pinned (onChange of groupsched)")
        //                            provider.updateSchedule(schedule: schedules[selectedSchedule])
        //                        }
        .onChange(of: selectedUniversity.1) { _, newValue in //TODO: Порождает баг, когда нет интернета и при повторной попытка нажать на тот же item ни пизды не произойдет, потому что onChange ебать его в попочку
            groups.removeAll()
            faculties.removeAll()

            if let cached = cachedFaculties[newValue] {
                faculties = cached
            } else {
                isLoadingFaculties = true
                getFacultiesUri(id: newValue) { facs in
                    DispatchQueue.main.async {
                        self.faculties = facs
                        self.cachedFaculties[newValue] = facs
                        isLoadingFaculties = false
                    }
                }
            }
        }
        .onChange(of: selectedFaculty.uri) { _, newValue in
            groups.removeAll()

            if let cached = cachedGroups[newValue] {
                groups = cached
            } else {
                isLoadingGroups = true
                getGroupsUri (id: selectedUniversity.1, uri: selectedFaculty.uri) { groups in
                    DispatchQueue.main.async {
                        self.groups = groups
                        self.cachedGroups[newValue] = groups
                        isLoadingGroups = false
                    }
                }
            }
        }
        .onChange(of: parity) {
            settingsManager.isEvenWeek = parityNames.firstIndex(of: parity) ?? 0
        }
        .onChange(of: dayTabBarPosition) {
            settingsManager.dayTabBarPosition = dayTabBarPosition == "Сверху"
        }
        .onChange(of: dayTabBarStyle) {
            settingsManager.dayTabBarStyle = dayTabBarStyle == "Округлый"
        }
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
