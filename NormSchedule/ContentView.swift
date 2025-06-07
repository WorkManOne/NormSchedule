//
//  ContentView.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 14.03.2024.
//
import SwiftData
import SwiftUI


struct ContentView: View {
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false
    @AppStorage("selectedScheduleID") private var selectedScheduleID: String?
    var selectedSchedule: GroupSched? {
        guard let idString = selectedScheduleID, let uuid = UUID(uuidString: idString) else { return nil }
        return schedules.first { $0.id == uuid }
    }

    @Environment(\.modelContext) var modelContext
    @Query(sort: \GroupSched.group) var schedules : [GroupSched]

    @EnvironmentObject var settingsManager : SettingsManager

    let universities = [UniversityModel(id: "1", name: "СГУ"), UniversityModel(id: "2", name: "СГТУ")]
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

    @State private var isFacultiesUpdated = false
    @State private var isGroupsUpdated = false
    @State private var isScheduleUpdated = false
    @State private var isTeachersUpdated = false

    @State private var isShowAlert = false
    @State private var alertMessage = ""

    @State private var cachedFaculties: [String: [FacultyModel]] = [:]
    @State private var cachedTeachers: [String: [TeacherModel]] = [:]
    @State private var cachedGroups: [String: [GroupModel]] = [:]

    @State private var faculties : [FacultyModel] = []
    @State private var groups: [GroupModel] = []
    @State private var teachers : [TeacherModel] = []

    @State private var selectedUniversity : UniversityModel?
    @State private var selectedFaculty : FacultyModel?
    @State private var selectedGroup : GroupModel?
    @State private var selectedTeacher : TeacherModel?

    var body: some View {
        TabView { //TODO: Попробовать убрать этот TabView, потому что он сеет баги при навигации, и дает меньше возможностей по кастомизации, сделать кастомный?
            ScheduleView(groupSchedule: selectedSchedule ?? GroupSched(university: "", faculty: "", group: "badInit", date_read: "", schedule: [], pinSchedule: [])) //TODO: решить случай nil
                .environmentObject(settingsManager)
                .tabItem { Image(systemName: "book.pages.fill").imageScale(.large) }
            NavigationStack {
                Form {
                    Section ("Выбор расписания") {
                        SchedulePicker
                    }
                    Section ("Настройки интерфейса") {
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
                    Section ("Университет для загрузки") {
                        UniversityPicker
                    }
                    Section ("Загрузить расписание группы") {
                        FacultyPicker
                        GroupPicker
                        Button(action: {
                            if (!groups.isEmpty) {
                                guard let uri = selectedGroup?.uri,
                                      let university = selectedUniversity else { return }
                                isLoadingSchedule = true

                                Task {
                                    if let parser = ParserManager.parser(for: university.id) {
                                        let result = await parser.getSchedule(uri: uri, university: selectedUniversity?.name, faculty: selectedFaculty?.name, group: selectedGroup?.name)

                                        switch result {
                                        case .success(let schedule):
                                            modelContext.insert(schedule)
                                            isLoadingSchedule = false
                                            isScheduleUpdated = true
                                        case .failure(let error):
                                            alertMessage = error.localizedDescription
                                            isShowAlert = true
                                            isLoadingSchedule = false
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
                    }
                    Section ("Загрузить расписание преподавателя") {
                        Button(action: {
                            guard let university = selectedUniversity else {
                                alertMessage = "Выберите университет"
                                isShowAlert = true
                                return
                            }
                            withAnimation {
                                isLoadingTeachers = true
                            }
                            Task {
                                if let parser = ParserManager.parser(for: university.id) {
                                    let result = await parser.getTeachers()
                                    withAnimation {
                                        switch result {
                                        case .success(let teachers):
                                            self.teachers = teachers
                                            isLoadingTeachers = false
                                            isTeachersUpdated = true
                                        case .failure(let error):
                                            alertMessage = error.localizedDescription
                                            isShowAlert = true
                                            isLoadingTeachers = false
                                        }
                                    }
                                }
                            }
                        }) {
                            Text("Загрузить преподавателей")
                        }
                        TeacherPicker
                        Button(action: {
                            if (!teachers.isEmpty) {
                                guard let uri = selectedTeacher?.uri,
                                      let university = selectedUniversity else { return }
                                isLoadingSchedule = true
                                Task {
                                    if let parser = ParserManager.parser(for: university.id) {
                                        let result = await parser.getSchedule(uri: uri, university: selectedUniversity?.name, faculty: nil, group: selectedTeacher?.name)

                                        switch result {
                                        case .success(let schedule):
                                            modelContext.insert(schedule)
                                            isLoadingSchedule = false
                                            isScheduleUpdated = true
                                        case .failure(let error):
                                            alertMessage = error.localizedDescription
                                            isShowAlert = true
                                            isLoadingSchedule = false
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
                    Section ("Помощь") {
                        Button {
                            withAnimation {
                                onboardingCompleted = false
                            }
                        } label : {
                            Label("Пройти обучение заново", systemImage: "lightbulb")
                        }
                        Button {
                            if let url = URL(string: "https://t.me/+5U0uw2xstjE1MzYy") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Label("Поддержка в Telegram", systemImage: "paperplane.circle.fill")
                        }
                        Button {
                            if let url = URL(string: "https://workmanone.github.io/NormSchedule-privacy-policy/") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Label("Политика конфиденциальности", systemImage: "text.document")
                        }
                    }
                    Section ("Системные настройки") {
                        Button(action: {
                            schedules.forEach { schedule in
                                modelContext.delete(schedule)
                            }
                        }) {
                            Text("Очистить всё расписание")
                        }
                        Button(action: {
                            cachedFaculties.removeAll()
                            cachedGroups.removeAll()
                            cachedTeachers.removeAll()
                        }) {
                            Text("Удалить кэшированные данные (факультеты, группы, преподаватели)")
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
        //TODO: я насоздавал слишком много всяких триггеров onChange - плохая практика, вообще везде надо глянуть onChange, код связанный с логикой и данными должен быть в коде а не в ui
        .onAppear {
            settingsManager.updateParityIfNeeded()
        }
        .onChange(of: selectedSchedule?.schedule) { // MARK: Забирает с собой случаи удаления расписания так что отдельный onChange на selectedSchedule не нужен
            print("sent Onchange schedule")
            SyncManager.shared.syncAll(
                schedule: selectedSchedule,
                parity: settingsManager.isEvenWeek
            )
        }
        .onChange(of: selectedSchedule?.pinSchedule) {
            print("sent Onchange pinSchedule")
            SyncManager.shared.syncAll(
                schedule: selectedSchedule,
                parity: settingsManager.isEvenWeek
            )
        }
        .onChange(of: settingsManager.isEvenWeek) {
            print("sent Onchange settingsManager")
            SyncManager.shared.syncAll(
                schedule: selectedSchedule,
                parity: settingsManager.isEvenWeek
            )
        }
        .onChange(of: parity) {
            let weekNumber = parityNames.firstIndex(of: parity) ?? 0
            settingsManager.isEvenWeek = weekNumber
        }
        .onChange(of: dayTabBarPosition) {
            settingsManager.dayTabBarPosition = dayTabBarPosition == "Сверху"
        }
        .onChange(of: dayTabBarStyle) {
            settingsManager.dayTabBarStyle = dayTabBarStyle == "Округлый"
        } //TODO: Блядский визуальный баг при навигации когда сверху чуть смещается вниз экран, типо когда с одного экрана на другой тыкаешь с навлинк и резко так экран вниз смещается (с которого переходишь)
        .alert("Ошибка", isPresented: $isShowAlert) {
            Button("Ок", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - Pickers
    private var SchedulePicker: some View {
        NavigationLink(destination:
                        SearchablePickerView(
                            title: "Выберите расписание",
                            selection: Binding<GroupSched?>(
                                get: { selectedSchedule },
                                set: { newValue in
                                    selectedScheduleID = newValue?.id.uuidString
                                }
                            ),
                            items: schedules,
                            searchKeyPath: \.group,
                            onSelect: { item in
                                SyncManager.shared.syncAll(schedule: item, parity: settingsManager.isEvenWeek)
                            },
                            onDelete: deleteSchedules
                        ) { item in
                            VStack (alignment: .leading) {
                                Text(item.university)
                                Text(item.faculty)
                                Text(item.group)
                                Text(item.date_read)
                                    .font(.footnote)
                            }
                        }.onAppear { withAnimation { isScheduleUpdated = false } }
        ) {
            HStack {
                Text("Расписание")
                Spacer()
                if isScheduleUpdated {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                        .transition(.scale)
                }
                Text(selectedSchedule?.group ?? "Не выбрано")
                    .foregroundColor(.secondary)
            }
        }
    }
    private var UniversityPicker: some View {
        NavigationLink(destination:
                        SearchablePickerView(
                            title: "Выберите университет",
                            selection: $selectedUniversity,
                            items: universities,
                            searchKeyPath: \.id,
                            onSelect: { _ in
                                universitySelect()
                            }
                        ) { item in
                            HStack {
                                Text(item.name)
                            }
                        }
        ) {
            HStack {
                Text("Университет")
                Spacer()
                Text(selectedUniversity?.name ?? "Не выбрано")
                    .foregroundColor(.secondary)
            }
        }
    }
    private var FacultyPicker: some View {
        NavigationLink(destination:
                        SearchablePickerView(
                            title: "Выберите факультет",
                            selection: $selectedFaculty,
                            items: faculties,
                            searchKeyPath: \.name,
                            onSelect: { _ in
                                facultySelect()
                            }
                        ) { item in
                            HStack {
                                Text(item.name)
                            }
                        }.onAppear { withAnimation { isFacultiesUpdated = false } }
        ) {
            HStack {
                Text("Факультет")
                Spacer()
                if isFacultiesUpdated {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                        .transition(.scale)
                }
                if isLoadingFaculties {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaledToFill()
                }
                Text(selectedFaculty?.name ?? "Не выбрано")
                    .foregroundColor(.secondary)
            }
        }
    }
    private var GroupPicker: some View {
        NavigationLink(destination:
                        SearchablePickerView(
                            title: "Выберите группу",
                            selection: $selectedGroup,
                            items: groups,
                            searchKeyPath: \.name
                        ) { item in
                            VStack(alignment: .leading) {
                                Text("\(item.name)")
                                Text("\(item.uri)")
                                    .foregroundStyle(.gray)
                                    .font(.footnote)
                            }
                        }.onAppear { withAnimation { isGroupsUpdated = false } }
        ) {
            HStack {
                Text("Группа")
                Spacer()
                if isLoadingGroups {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaledToFill()
                }
                if isGroupsUpdated {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                        .transition(.scale)
                }
                Text(selectedGroup?.name ?? "Не выбрано")
                    .foregroundColor(.secondary)
            }
        }
    }

    private var TeacherPicker: some View {
        NavigationLink(destination:
                        SearchablePickerView(
                            title: "Выберите учителя",
                            selection: $selectedTeacher,
                            items: teachers,
                            searchKeyPath: \.name
                        ) { item in
                            Text("\(item.name)")
                        }.onAppear { withAnimation { isTeachersUpdated = false } }
        ) {
            HStack {
                Text("Преподаватель")
                Spacer()
                if isTeachersUpdated {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                        .transition(.scale)
                }
                if isLoadingTeachers {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaledToFill()
                }
                Text(selectedTeacher?.name ?? "Не выбрано")
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Data functions
    
    func deleteSchedules(_ indexSet: IndexSet) {
        for index in indexSet {
            let schedule = schedules[index]
            modelContext.delete(schedule)
        }
    }
    private func universitySelect() {
        guard let university = selectedUniversity else { return }
        selectedGroup = nil
        selectedFaculty = nil
        selectedTeacher = nil
        isGroupsUpdated = false
        isFacultiesUpdated = false
        isTeachersUpdated = false
        groups.removeAll()
        faculties.removeAll()

        if let cached = cachedFaculties[university.id] {
            faculties = cached
            withAnimation {
                isFacultiesUpdated = true
            }
        } else {
            withAnimation {
                isLoadingFaculties = true
            }
            Task {
                if let parser = ParserManager.parser(for: university.id) {
                    let result = await parser.getFaculties()
                    withAnimation {
                        switch result {
                        case .success(let facs):
                            self.faculties = facs
                            self.cachedFaculties[university.id] = facs
                            isLoadingFaculties = false
                            isFacultiesUpdated = true
                        case .failure(let error):
                            alertMessage = error.localizedDescription
                            isShowAlert = true
                            isLoadingFaculties = false
                        }
                    }
                }
            }
        }
    }
    private func facultySelect() {
        guard let uri = selectedFaculty?.uri,
              let university = selectedUniversity else { return }
        groups.removeAll()
        selectedGroup = nil
        isGroupsUpdated = false

        if let cached = cachedGroups[uri] {
            groups = cached
            withAnimation {
                isGroupsUpdated = true
            }
        } else {
            withAnimation {
                isLoadingGroups = true
            }
            Task {
                if let parser = ParserManager.parser(for: university.id) {
                    let result = await parser.getGroups(uri: uri)
                    withAnimation {
                        switch result {
                        case .success(let groups):
                            self.groups = groups
                            self.cachedGroups[uri] = groups
                            isLoadingGroups = false
                            isGroupsUpdated = true
                        case .failure(let error):
                            alertMessage = error.localizedDescription
                            isShowAlert = true
                            isLoadingGroups = false
                        }
                    }

                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SettingsManager())
}
