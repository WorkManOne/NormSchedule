//
//  LessonRowView.swift
//  NormWidgetExtension
//
//  Created by Кирилл Архипов on 16.04.2025.
//

import SwiftUI
import WidgetKit

struct LessonRowView: View {
    var title: String? = nil
    var lesson: Lesson
    var info: String? = nil
    var infoImage: Image? = nil
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        VStack (alignment: .leading, spacing: 0) {
            if let title = title {
                HStack {
                    Text(title)
                        .lineLimit(1)
                        .fontWeight(family != .accessoryRectangular ? .bold : .regular)
                        .minimumScaleFactor(0.5)
                        .padding(.bottom, 2)
                    Spacer()
                    if let info = info, family == .accessoryRectangular {
                        if let infoImage = infoImage {
                            infoImage
                        }
                        Text(info)
                            .fontWeight(.black)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                }
            }
            if family != .accessoryRectangular {
                HStack {
                    Text(lesson.timeString())
                        .font(.caption)
                    Spacer()
                    if let icon = lesson.importance.icon {
                        icon
                            .foregroundStyle(lesson.importance.iconColor)
                            .imageScale(.small)
                    }
                }
            }
            HStack {
                RoundedRectangle(cornerRadius: 3)
                    .frame(width: 3)
                    .foregroundStyle(.blue)
                VStack (alignment: .leading, spacing: 0) {
                    Text(lesson.name)
                        .font(.system(size: family != .accessoryRectangular ? 16 : 12))
                        .fontWeight(family != .accessoryRectangular ? .regular : .black)
                        .padding(.leading, 5)
                    HStack (spacing: 0) {
                        if family == .systemMedium || family == .systemLarge || family == .systemExtraLarge {
                            if !lesson.teacher.isEmpty {
                                Image(systemName: "person.fill")
                                Text(lesson.teacher)
                                Spacer()
                            }
                        }
                        if family == .systemExtraLarge {
                            if !lesson.parity.isEmpty {
                                Image(systemName: "calendar")
                                Text(lesson.parity.values.first ?? "")
                                    .padding(.trailing)
                            }
                            if !lesson.type.isEmpty {
                                Image(systemName: "book")
                                Text(lesson.type)
                                    .padding(.trailing)
                            }
                            if !lesson.subgroup.isEmpty {
                                Image(systemName: "person.3")
                                Text(lesson.subgroup)
                                    .padding(.trailing)
                            }
                        }
                        if !lesson.place.isEmpty && family != .accessoryRectangular {
                            Image(systemName: "mappin")
                            Text(lesson.place)
                                .truncationMode(.middle)
                        }
                    }
                    .font(.caption2)
                    .fontWeight(.light)
                }
                //                .id(lesson)
                //                .transition(.push(from: .bottom))
            }
        }
    }
}

//#Preview {
//    LessonRowView(lesson: Lesson(timeStart: 30000, timeEnd: 32000, type: "лекция", subgroup: "подгр. 2", parity: [:], name: "Вставьте большое название предмета сюда", teacher: "Вставьте фамилию преподавательевич", place: "Стадион Сокол"))
//}

#Preview(as: .systemExtraLarge) {
    LargeListWidget()
} timeline: {
    LargeListWidgetEntry(date: .now,
                         lessons: [WidgetDataManager.LessonWithTitle(lesson: Lesson(timeStart: 30000, timeEnd: 32000, type: "практ.", subgroup: "2", parity: [:], name: "Программирование и конфигурирование в компьютерных сетях", teacher: "Кабанова Любовь Александровна", place: "12 корпус 414 ауд."), title: "Cейчас"),
                                   WidgetDataManager.LessonWithTitle(lesson: Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"), title: "Далее"),
                                   WidgetDataManager.LessonWithTitle(lesson: Lesson(timeStart: 42000, timeEnd: 45000, type: "лекция.", subgroup: "", parity: [:], name: "Компьютерные сети", teacher: "Мистер Лектор", place: "Аудитория 215"), title: nil),
                                   WidgetDataManager.LessonWithTitle(lesson: Lesson(timeStart: 46000, timeEnd: 50000, type: "лекция.", subgroup: "", parity: [:], name: "Пример пары", teacher: "Пример преподавателя", place: "12 к. 310"), title: nil),
                                   WidgetDataManager.LessonWithTitle(lesson: Lesson(timeStart: 30000, timeEnd: 32000, type: "практика.", subgroup: "подгр. 1", parity: [true:"чет."], name: "Статистический анализ данных", teacher: "Иванов Иван Иванович", place: "10 к. 418 ауд."), title: "Завтра"),
                                   WidgetDataManager.LessonWithTitle(lesson: Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"), title: "Понедельник"),
                                   WidgetDataManager.LessonWithTitle(lesson: Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"), title: "Вторник")])
}
