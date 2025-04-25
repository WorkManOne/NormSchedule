//
//  ProgressAccessoryWidgetView.swift
//  NormWidgetExtension
//
//  Created by Кирилл Архипов on 25.04.2025.
//

import SwiftUI
import WidgetKit

struct ProgressAccessoryWidgetView: View {
    @Environment(\.widgetFamily) var family
    var entry: ProgressAccessoryWidgetEntry

    var body: some View {
        switch family {
        case .accessoryCircular:
            VStack (spacing: 0) {
                Text(entry.timeStart)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    //.allowsTightening(true)
                    //.minimumScaleFactor(0.5) //TODO: Из-за этого может плохо работать на устройствах с маленьким экраном, но для этого нужны реальные тесты (не критично)
                    .padding(.bottom, 4)
                Gauge(value: entry.progress){}
                    .gaugeStyle(.accessoryLinearCapacity)
                Text(entry.timeEnd)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    //.allowsTightening(true)
                    //.minimumScaleFactor(0.5)
                    .padding(.top, 5)
            }.frame(maxWidth: .infinity, alignment: .center)
        case .accessoryRectangular:
            VStack {
                HStack {
                    Text(entry.timeStart)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .allowsTightening(true)
                        .minimumScaleFactor(0.5)
                    Gauge(value: entry.progress){}
                        .gaugeStyle(.accessoryLinearCapacity)
                    Text(entry.timeEnd)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .allowsTightening(true)
                        .minimumScaleFactor(0.5)
                }
                Text(entry.lessonName)
            }.frame(maxWidth: .infinity, alignment: .center)
        default:
            Text("Не поддерживается")
        }
    }
}


#Preview(as: .accessoryCircular) {
    ProgressAccessoryWidget()
} timeline: {
    ProgressAccessoryWidgetEntry(date: .now, progress: 0.2, lessonName: "Программирование и конфигурирование в компьютерных сетях", timeStart: "12:30", timeEnd: "23:12")
    ProgressAccessoryWidgetEntry(date: .now, progress: 0.4, lessonName: "Программирование и конфигурирование в компьютерных сетях", timeStart: "12:30", timeEnd: "23:12")
    ProgressAccessoryWidgetEntry(date: .now, progress: 0.6, lessonName: "Программирование и конфигурирование в компьютерных сетях", timeStart: "12:30", timeEnd: "23:12")
    ProgressAccessoryWidgetEntry(date: .now, progress: 0.8, lessonName: "Программирование и конфигурирование в компьютерных сетях", timeStart: "12:30", timeEnd: "23:12")
    ProgressAccessoryWidgetEntry(date: .now, progress: 1.0, lessonName: "Пары нет", timeStart: "--:--", timeEnd: "--:--")
}
