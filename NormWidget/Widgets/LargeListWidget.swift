//
//  LargeListWidget.swift
//  NormWidgetExtension
//
//  Created by Кирилл Архипов on 15.04.2025.
//

import WidgetKit
import SwiftUI

struct LargeListWidgetEntry: TimelineEntry {
    var date: Date
    let lessons: [DataManager.LessonWithTitle] //TODO: мда блять, интересненькая имплементация структуру, ебучий вонючий, ну я хуй знает как это архитектурно правильно сделать, один хуй используется только тут
}

struct LargeListWidgetView : View {
    var entry: LargeListWidgetEntry

    var body: some View {
        if entry.lessons.isEmpty {
            Text("Занятий нет")
                .fontWeight(.bold)
        } else {
            VStack(alignment: .leading, spacing: 0) { //TODO: Мне если честно не очень нравится то, что показывается просто список без обозначений Сейчас/Далее/Завтра/Четверг
                ForEach(entry.lessons.prefix(6).indices, id: \.self) { index in
                    let lesson = entry.lessons[index]
                    LessonRowView(title: lesson.title, lesson: lesson.lesson)
                        //.padding(.vertical, 4)
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }
}

struct LargeListWidget: Widget {
    let kind: String = "LargeListWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: LargeListWidgetProvider()
        ) { entry in
            if #available(iOS 17.0, *) {
                LargeListWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                LargeListWidgetView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Список ближайших занятий")
        .description("Список занятий во временном порядке их следования")
        .supportedFamilies([.systemLarge, .systemExtraLarge])
    }
}

#Preview(as: .systemLarge) {
    LargeListWidget()
} timeline: {
    LargeListWidgetEntry(date: .now,
                         lessons: [DataManager.LessonWithTitle(lesson: Lesson(timeStart: 30000, timeEnd: 32000, type: "практ.", subgroup: "2", parity: [:], name: "Программирование и конфигурирование в компьютерных сетях", teacher: "Кабанова Любовь Александровна", place: "12 корпус 414 ауд."), title: "Cейчас"),
                                   DataManager.LessonWithTitle(lesson: Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"), title: "Далее"),
                                   DataManager.LessonWithTitle(lesson: Lesson(timeStart: 42000, timeEnd: 45000, type: "лекция.", subgroup: "", parity: [:], name: "Компьютерные сети", teacher: "Мистер Лектор", place: "Аудитория 215"), title: nil),
                                   DataManager.LessonWithTitle(lesson: Lesson(timeStart: 46000, timeEnd: 50000, type: "лекция.", subgroup: "", parity: [:], name: "Пример пары", teacher: "Пример преподавателя", place: "12 к. 310"), title: nil),
                                   DataManager.LessonWithTitle(lesson: Lesson(timeStart: 30000, timeEnd: 32000, type: "практика.", subgroup: "подгр. 1", parity: [true:"чет."], name: "Статистический анализ данных", teacher: "Иванов Иван Иванович", place: "10 к. 418 ауд."), title: "Завтра"),
                                   DataManager.LessonWithTitle(lesson: Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"), title: "Понедельник"),
                                   DataManager.LessonWithTitle(lesson: Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"), title: "Вторник")])
}
