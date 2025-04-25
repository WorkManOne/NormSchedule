//
//  CircularCurNextAccessoryWidgetView.swift
//  NormWidgetExtension
//
//  Created by Кирилл Архипов on 18.04.2025.
//

import SwiftUI
import WidgetKit

struct CircularCurNextAccessoryWidgetView : View {
    var entry: CurNextWidgetEntry
    var titleText: String {
        if entry.configuration.showCurrent && entry.currentLesson != nil {
            return "Конец"
        } else if entry.configuration.showNext && entry.nextLesson != nil {
            return "Начало"
        } else {
            return "Пар нет"
        }
    }

    var timeText: String {
        if entry.configuration.showCurrent, let curLesson = entry.currentLesson {
            return curLesson.timeEndString()
        } else if entry.configuration.showNext, let nextLesson = entry.nextLesson {
            return nextLesson.timeStartString()
        } else {
            return ""
        }
    }

    var body: some View {
        VStack {
            Image(systemName: titleText == "Конец" ? "book.fill" : "hourglass") //TODO: Ебанутая логика по строке условие вычислять (особенно если я задумаю локализацию)
            if entry.configuration.showLabels {
                Text(titleText)
                    .fontWeight(.black)
                    .lineLimit(1)
                    .allowsTightening(true)
                    .minimumScaleFactor(0.5)
            }
            Text(timeText)
                .lineLimit(1)
                .allowsTightening(true)
                .minimumScaleFactor(0.5)
        }
        .multilineTextAlignment(.center)
    }
}


#Preview(as: .accessoryCircular) {
    CurNextWidget()
} timeline: {
    CurNextWidgetEntry(date: .now,
                       currentLesson: Lesson(timeStart: 30000, timeEnd: 32000, type: "практ.", subgroup: "2", parity: [:], name: "Программирование и конфигурирование в компьютерных сетях", teacher: "Кабанова Любовь Александровна", place: "12 корпус 414 ауд."),
                       nextLesson: Lesson(timeStart: 34000, timeEnd: 40000, type: "лекция.", subgroup: "", parity: [:], name: "Языки программирования", teacher: "Мистер Мирон", place: "12 к. 310"), nextTitle: "Далее", configuration: CurNextWidgetConfigurationAppIntent())
    CurNextWidgetEntry(date: .now,
                       currentLesson: nil,
                       nextLesson: Lesson(timeStart: 45000, timeEnd: 80000, type: "лекция.", subgroup: "", parity: [:], name: "Математическая логика", teacher: "Молчанов", place: "12 корпус 420"), nextTitle: "Далее", configuration: CurNextWidgetConfigurationAppIntent())
    CurNextWidgetEntry(date: .now,
                       currentLesson: nil,
                       nextLesson: nil, nextTitle: "Далее", configuration: CurNextWidgetConfigurationAppIntent())
}
