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
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack (alignment: .leading, spacing: 0) {
            if let title = title {
                Text(title)
                    .fontWeight(.bold)
                    .padding(.bottom, 2)
            }
            Text(lesson.timeString())
                .font(.caption)
            HStack {
                RoundedRectangle(cornerRadius: 3)
                    .frame(width: 3)
                    .foregroundStyle(.blue)
                VStack (alignment: .leading, spacing: 0) {
                    Text(lesson.name)
                        .font(.system(size: 16))
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
                        if !lesson.place.isEmpty {
                            Image(systemName: "mappin")
                            Text(lesson.place)
                        }
                    }
                    .font(.caption2)
                    .fontWeight(.light)
                    .opacity(1)
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
                         lessons: [
                            Lesson(timeStart: 30000, timeEnd: 32000, type: "практ.", subgroup: "2 подгруппа", parity: [true:"чет."], name: "Программирование и конфигурирование в компьютерных сетях", teacher: "Кабанова Любовь Александровна", place: "12 корпус 414 ауд."),
                            Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"),
                            Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"),
                            Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"),
                            Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"),
                            Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"),
                            Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"),
                            Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"),
                            Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310")])
}
