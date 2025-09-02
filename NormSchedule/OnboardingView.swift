//
//  OnboardingView.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 10.05.2025.
//

import SwiftUI

struct OnboardingView: View {
    let onFinished: () -> Void
    @State private var step: Int = 0
    private let totalSteps = 8

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    if step < totalSteps - 1 {
                        Button("Пропустить") {
                            withAnimation {
                                step = totalSteps - 1
                            }
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.secondary)
                    }
                }.padding(.trailing)

                Spacer()

                TabView(selection: $step) {
                    StepWelcome()
                        .tag(0)
                    StepDownload()
                        .tag(1)
                    StepLessonLight()
                        .tag(2)
                    StepLessonLightNote()
                        .tag(3)
                    StepLessonLightPin()
                        .tag(4)
                    StepParity()
                        .tag(5)
                    StepLesson()
                        .tag(6)
                    StepDone()
                        .tag(7)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: step)

                //Spacer()
                HStack(spacing: 8) {
                    ForEach(0..<totalSteps, id: \.self) { index in
                        Circle()
                            .fill(index == step ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding()
                HStack {
                    if step > 0 {
                        Button(action: {
                            withAnimation { step -= 1 }
                        }) {
                            Text("Назад")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.frame)
                                .cornerRadius(12)
                        }
                    }

                    Button(action: {
                        withAnimation {
                            if step < totalSteps - 1 {
                                step += 1
                            } else {
                                onFinished()
                            }
                        }
                    }) {
                        Text(step == totalSteps - 1 ? "Готово" : "Далее")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.lines)
                            .cornerRadius(12)
                    }
                }
                .controlSize(.large)
                .padding([.horizontal, .bottom])
            }
        }
        .onAppear {
            UIPageControl.appearance().currentPageIndicatorTintColor = .blue
            UIPageControl.appearance().pageIndicatorTintColor = UIColor(named: "lines")
            UIPageControl.appearance().tintColor = UIColor(named: "lines")
        }
    }
}

struct StepWelcome: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image("LaunchIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 100)
            Text("Добро пожаловать!")
                .font(.largeTitle).bold()
            Text("Чтобы познакомиться со всеми функциями приложения рекомендуем пройти обучение.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            Text("Вы сможете вернуться к обучению в любой момент времени в настройках.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            Spacer()
        }
    }
}

struct StepDownload: View {
    let universities = [UniversityModel(id: "1", name: "СГУ"), UniversityModel(id: "2", name: "СГТУ")]
    @State private var faculties : [FacultyModel] = []
    @State private var groups: [GroupModel] = []
    @State private var teachers : [TeacherModel] = []
    @State private var schedules : [GroupSched] = []

    @State private var selectedUniversity : UniversityModel?
    @State private var selectedFaculty : FacultyModel?
    @State private var selectedGroup : GroupModel?
    @State private var selectedSchedule: GroupSched?

    @State private var isLoadingSchedule = false
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Загрузка")
                .font(.title.bold())
            Spacer(minLength: 0)
            Text("Загружайте расписания себе на устройство в любое время!")
                .font(.system(size: 20))
                .fontWeight(.regular)
            Text("(с помощью технологии парсинга)")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
            Text("Больше не нужно ждать чьих то серверов и их синхронизацию.")
                .font(.system(size: 14))
                .fontWeight(.regular)
                .padding(.top, 5)
            VStack(spacing: 0) {
                Group {
                    UniversityPicker
                    FacultyPicker
                    GroupPicker
                    Button(action: {
                        if !groups.isEmpty {
                            isLoadingSchedule = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                schedules.append(GroupSched(university: selectedUniversity?.name ?? "", faculty: selectedFaculty?.name ?? "", group: selectedGroup?.name ?? "", date_read: Date.now.description, schedule: [], pinSchedule: []))
                                isLoadingSchedule = false
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
                    }.frame(maxWidth: .infinity)
                    SchedulePicker
                }
                .padding(.horizontal)
                .padding(.vertical, 15)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity, alignment: .leading)

            }
            Text("Загрузка доступна, пока работает сайт вашего вуза с расписанием.")
                .font(.system(size: 14))
                .fontWeight(.regular)
            Text("Все загруженные расписания хранятся на вашем устройстве.")
                .font(.system(size: 14))
                .fontWeight(.regular)
            Spacer(minLength: 0)
        }
        .multilineTextAlignment(.center)
        .padding([.horizontal], 20)
    }

    private var UniversityPicker: some View {
        NavigationLink(destination:
                        SearchablePickerView(
                            title: "Выберите университет",
                            selection: $selectedUniversity,
                            items: universities,
                            searchKeyPath: \.id,
                            onSelect: { _ in
                                faculties = [FacultyModel(name: "Факультет 1 \(selectedUniversity?.name ?? "")", uri: "facultyUri1"),
                                             FacultyModel(name: "Факультет 2 \(selectedUniversity?.name ?? "")", uri: "facultyUri2"),
                                             FacultyModel(name: "Факультет 3 \(selectedUniversity?.name ?? "")", uri: "facultyUri3")]
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
                                groups = [GroupModel(name: "Группа 1 \(selectedFaculty?.name ?? "")", uri: "groupUri1"), GroupModel(name: "Группа 2 \(selectedFaculty?.name ?? "")", uri: "groupUri2"), GroupModel(name: "Группа 3 \(selectedFaculty?.name ?? "")", uri: "groupUri3")]
                            }
                        ) { item in
                            HStack {
                                Text(item.name)
                            }
                        }
        ) {
            HStack {
                Text("Факультет")
                Spacer()
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
                        }
        ) {
            HStack {
                Text("Группа")
                Spacer()
                Text(selectedGroup?.name ?? "Не выбрано")
                    .foregroundColor(.secondary)
            }
        }
    }
    private var SchedulePicker: some View {
        NavigationLink(destination:
                        SearchablePickerView(
                            title: "Выберите расписание",
                            selection: $selectedSchedule,
                            items: schedules,
                            searchKeyPath: \.group
                        ) { item in
                            VStack (alignment: .leading) {
                                Text(item.university)
                                Text(item.faculty)
                                Text(item.group)
                                Text(item.date_read)
                                    .font(.footnote)
                            }
                        }
        ) {
            HStack {
                Text("Расписание")
                Spacer()
                Text(selectedSchedule?.group ?? "Не выбрано")
                    .foregroundColor(.secondary)
            }
        }
    }

}

struct StepLessonLight: View {
    @State private var pinned = [Bool: UUID]()
    @State private var lessons = [Lesson(timeStart: 30000, timeEnd: 40000, type: "практ.", subgroup: "Подгр. 2", parity: [true:"Четная"], name: "Практическая пара с практическими знаниями", teacher: "Преподаватель", place: "Ауд. 208")]
    var body: some View {
        VStack(spacing: 16) {
            Text("Занятие")
                .font(.title.bold())
            Spacer(minLength: 0)
            LessonView(lessons: $lessons, pinned: $pinned)
                .environmentObject(SettingsManager.shared)
                .disabled(true)
            Text("Содержит всю необходимую информацию о занятии позволяя быстро ориентироваться в любой ситуации")
                .font(.system(size: 20))
                .fontWeight(.regular)
                .padding(.horizontal, 20)
            Spacer(minLength: 0)
        }
        .multilineTextAlignment(.center)
    }
}

struct StepLessonLightNote: View {
    @State private var pinned = [Bool: UUID]()
    @State private var lessons = [Lesson(timeStart: 30000, timeEnd: 40000, type: "практ.", subgroup: "Подгр. 2", parity: [false:"Нечетная"], name: "Практическая пара с практическими знаниями", teacher: "Преподаватель", place: "Ауд. 208", note: NSAttributedString(string: "TestNote"))]
    var body: some View {
        VStack(spacing: 16) {
            Text("Занятие")
                .font(.title.bold())
            Spacer(minLength: 0)
            Text("На занятия можно оставлять заметки")
                .font(.system(size: 18))
                .fontWeight(.regular)
                .padding(.horizontal, 20)
            LessonView(lessons: $lessons, pinned: $pinned)
                .environmentObject(SettingsManager.shared)
                .disabled(true)
            Text("Занятия с заметками помечаются желтым маркером на уголках")
                .font(.system(size: 16))
                .padding(.horizontal, 20)
            Spacer(minLength: 0)
        }
        .multilineTextAlignment(.center)
    }
}

struct StepLessonLightPin: View { //TODO: ПРОВЕРИТЬ НА РАБОТОСПОСОБНОСТЬ
    @State private var pinned = [true: UUID(uuidString: "12345678-1234-1234-1234-123456789ABC")!, false: UUID(uuidString: "87654321-4321-4321-4321-CBA987654321")!]
    @State private var lessons = [
        Lesson(id: UUID(uuidString: "12345678-1234-1234-1234-123456789ABC")!, timeStart: 30000, timeEnd: 40000, type: "практ.", subgroup: "Подгр. 2", parity: [true:"Четная"], name: "Практическая пара с практическими знаниями", teacher: "Преподаватель", place: "Ауд. 208"),
        Lesson(id: UUID(uuidString: "87654321-4321-4321-4321-CBA987654321")!, timeStart: 30000, timeEnd: 40000, type: "практ.", subgroup: "Подгр. 1", parity: [false:"Нечетная"], name: "Пара другой недели", teacher: "Преподаватель 2", place: "Ауд. 210")
    ]
    var body: some View {
        VStack(spacing: 16) {
            Text("Занятие")
                .font(.title.bold())
            Spacer(minLength: 0)
            Text("Закрепленные занятия помечаются булавкой")
                .font(.system(size: 18))
                .fontWeight(.bold)
                .padding([.horizontal], 20)
            Text("Такие занятия всегда на виду")
            //.font(.system(size: 18))
                .foregroundStyle(.secondary)
            HStack {
                VStack {
                    Image(systemName: "pin.fill")
                        .foregroundStyle(.blue)
                        .opacity(0.75)
                    Text("Четная")
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack {
                    ZStack {
                        Image(systemName: "pin.fill")
                            .foregroundStyle(.blue)
                            .opacity(0.75)
                        Image(systemName: "pin.fill")
                            .foregroundStyle(.red)
                            .opacity(0.75)
                    }
                    Text("Без четности")
                }
                .frame(maxWidth: .infinity)

                VStack {
                    Image(systemName: "pin.fill")
                        .foregroundStyle(.red)
                        .opacity(0.75)
                    Text("Нечетная")
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal, 20)
            LessonView(lessons: $lessons, pinned: $pinned)
                .environmentObject(SettingsManager.shared)
            //.disabled(true)
            Text("Попробуйте полистать")
            //.font(.system(size: 18))
                .foregroundStyle(.secondary)
            Spacer(minLength: 0)
        }
        .multilineTextAlignment(.center)
    }
}

struct StepParity: View {
    @State private var parity = "Нет"
    let parityNames = ["Нет", "Чет", "Нечет"]

    var body: some View {
        VStack(spacing: 16) {
            Text("Отображение актуального")
                .font(.title.bold())
                .padding(.horizontal)
            Spacer(minLength: 0)
            Text("Четность недель")
                .font(.title2.bold())
            Spacer(minLength: 0)
            Text("Эта настройка помогает отслеживать актуальные занятия на текущей неделе.")
                .font(.system(size: 16))
                .padding(.horizontal)
            Picker(selection: $parity, label: Text("Четность недели")) {
                ForEach(parityNames, id: \.self) { name in
                    Text(name)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            Text("Установите настройку один раз и она будет автоматически переключаться каждую неделю.")
                .font(.system(size: 16))
                .padding(.horizontal)
            Spacer(minLength: 0)
            Spacer(minLength: 0)
        }
        .multilineTextAlignment(.center)
    }
}

struct StepLesson: View {
    @EnvironmentObject var settingsManager : SettingsManager
    @State private var parity = "Нет"
    let parityNames = ["Нет", "Чет", "Нечет"]
    @State private var pinned = [true: UUID(uuidString: "87654321-4321-4321-4321-CBA987654321")!, false: UUID(uuidString: "12345678-1234-1234-1234-123456789ABC")!]
    @State private var lessons = [
        Lesson.mock(id: UUID(uuidString: "87654321-4321-4321-4321-CBA987654321")!),
        Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [true:"Четная"], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"),
        Lesson(id: UUID(uuidString: "12345678-1234-1234-1234-123456789ABC")!, timeStart: 34000, timeEnd: 40000, type: "практ.", subgroup: "Подгр. 2", parity: [false:"Нечетная"], name: "Практическая пара с практическими знаниями", teacher: "Фамилия И. О.", place: "Аудитория 208")]
    var body: some View {
        VStack(spacing: 16) {
            Text("Отображение актуального")
                .font(.title.bold())
                .padding(.horizontal)
            Spacer(minLength: 0)
            Text("Познакомьтесь с контекстным меню")
                .font(.title3)
            Text("и опробуйте новые возможности в деле.")
                .foregroundStyle(.secondary)
            Text("Нажмите и удерживайте палец на занятии чтобы вызвать меню.")
                .font(.system(size: 16))
                .padding(.horizontal)
            LessonView(lessons: $lessons, pinned: $pinned)
                .environmentObject(settingsManager)
            Picker(selection: $parity, label: Text("Четность недели")) {
                ForEach(parityNames, id: \.self) { name in
                    Text(name)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            Spacer(minLength: 0)
        }
        .multilineTextAlignment(.center)
        .onChange(of: parity) {
            let weekNumber = parityNames.firstIndex(of: parity) ?? 0
            settingsManager.isEvenWeek = weekNumber
        }
        .onAppear {
            parity = parityNames[settingsManager.isEvenWeek]
        }
    }
}

struct StepDone: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)
            Text("Готово!")
                .font(.largeTitle).bold()
            Text("Вы готовы начать пользоваться приложением.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
    }
}



#Preview {
    OnboardingView(onFinished: {})
}
