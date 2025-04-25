//
//  RectangleCurNextAccessoryWidgetView.swift
//  NormWidgetExtension
//
//  Created by Кирилл Архипов on 18.04.2025.
//

import SwiftUI
import WidgetKit

struct LessonDisplayItem {
    var label: String?
    var lesson: Lesson
    var info: String?
    var infoImage: Image?
}

struct CurNextWidgetView : View {
    var entry: CurNextWidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            CircularCurNextAccessoryWidgetView(entry: entry)
        default:
            let items = buildItems(isAccessoryWidget: family == .accessoryRectangular)
            VStack(alignment: .leading) {
                ForEach(items.indices, id: \.self) { index in
                    let item = items[index]
                    LessonRowView(title: item.label, lesson: item.lesson, info: item.info, infoImage: item.infoImage)
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    func getInfo(for lesson: Lesson, isNowLesson: Bool) -> (info: String, image: Image) {
        switch entry.configuration.selectedInfoField {
        case .teacher:
            (lesson.teacher, Image(systemName: "person.fill"))
        case .time:
            (isNowLesson ? lesson.timeEndString() : lesson.timeStartString(), Image(systemName: "clock"))
        case .place:
            (lesson.place, Image(systemName: "mappin"))
        case .type:
            (lesson.type, Image(systemName: "book"))
        case .subgroup:
            (lesson.subgroup, Image(systemName: "person.3"))
        case .parity:
            (lesson.parity.values.first ?? "", Image(systemName: "calendar"))
        }
    }
    func buildItems(isAccessoryWidget: Bool) -> [LessonDisplayItem] {
        var items: [LessonDisplayItem] = []

        if entry.configuration.showCurrent {
            if let currentLesson = entry.currentLesson {
                if let nextLesson = entry.nextLesson, entry.configuration.showBoth && entry.configuration.showNext {
                    let (info1, image1) = getInfo(for: currentLesson, isNowLesson: true)
                    let (info2, image2) = getInfo(for: nextLesson, isNowLesson: false)
                    items.append(LessonDisplayItem(label: !isAccessoryWidget && entry.configuration.showLabels ? "Сейчас" : nil, lesson: currentLesson, info: info1, infoImage: image1))
                    items.append(LessonDisplayItem(label: !isAccessoryWidget && entry.configuration.showLabels ? entry.nextTitle ?? "Далее" : nil, lesson: nextLesson, info: info2, infoImage: image2))
                }
                else {
                    let (info1, image1) = getInfo(for: currentLesson, isNowLesson: true)
                    items.append(LessonDisplayItem(label: entry.configuration.showLabels ? "Сейчас" : nil, lesson: currentLesson, info: info1, infoImage: image1))
                }
            } else {
                if entry.configuration.showNext {
                    if let nextLesson = entry.nextLesson {
                        let (info2, image2) = getInfo(for: nextLesson, isNowLesson: false)
                        items.append(LessonDisplayItem(label: entry.configuration.showLabels ? entry.nextTitle ?? "Далее" : nil, lesson: nextLesson, info: info2, infoImage: image2))
                    } else {
                        items.append(LessonDisplayItem(label: nil, lesson: Lesson(timeStart: 0, timeEnd: 0, type: "", subgroup: "", parity: [:], name: "Пар нет", teacher: "", place: "")))
                    }
                } else {
                    items.append(LessonDisplayItem(label: entry.configuration.showLabels ? "Сейчас" : nil, lesson: Lesson(timeStart: 0, timeEnd: 0, type: "", subgroup: "", parity: [:], name: "Пары нет", teacher: "", place: "")))
                }
            }
        } else if entry.configuration.showNext {
            if let nextLesson = entry.nextLesson {
                let (info2, image2) = getInfo(for: nextLesson, isNowLesson: false)
                items.append(LessonDisplayItem(label: entry.configuration.showLabels ? entry.nextTitle ?? "Далее" : nil, lesson: nextLesson, info: info2, infoImage: image2))
            } else {
                items.append(LessonDisplayItem(label: entry.configuration.showLabels ? entry.nextTitle ?? "Далее" : nil, lesson: Lesson(timeStart: 0, timeEnd: 0, type: "", subgroup: "", parity: [:], name: "Пары нет", teacher: "", place: "")))
            }
        } else {
            return [LessonDisplayItem(label: nil, lesson: Lesson(timeStart: 0, timeEnd: 0, type: "", subgroup: "", parity: [:], name: "Настройте", teacher: "", place: ""))]
        }
        return items
    }

}

#Preview(as: .accessoryRectangular) {
    CurNextWidget()
} timeline: {
    CurNextWidgetEntry(date: .now,
                       currentLesson: Lesson(timeStart: 30000, timeEnd: 32000, type: "практ.", subgroup: "2", parity: [:], name: "Программирование и конфигурирование в компьютерных сетях", teacher: "Кабанова Любовь Александровна", place: "12 корпус 414 ауд."),
                       nextLesson: Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"), nextTitle: "Далее", configuration: CurNextWidgetConfigurationAppIntent())
    CurNextWidgetEntry(date: .now,
                       currentLesson: Lesson(timeStart: 45000, timeEnd: 80000, type: "лекция.", subgroup: "", parity: [:], name: "Математическая логика", teacher: "Молчанов", place: "12 корпус 420"),
                       nextLesson: nil, nextTitle: "Далее", configuration: CurNextWidgetConfigurationAppIntent())
    CurNextWidgetEntry(date: .now,
                       currentLesson: nil,
                       nextLesson: nil, nextTitle: "Далее", configuration: CurNextWidgetConfigurationAppIntent())
}
