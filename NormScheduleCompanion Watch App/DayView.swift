//
//  DayView.swift
//  NormScheduleCompanion Watch App
//
//  Created by Кирилл Архипов on 03.03.2025.
//

import Foundation
import SwiftUI

struct DayView: View {
    let day: String
    var daySched : [[Lesson]]
    @EnvironmentObject var settingsManager: SettingsManager
    @Binding var pinSched : [[Bool:Int]]

    var body: some View {
        VStack {
            Text(day)
            List {
                ForEach (daySched.indices, id: \.self) { index in
                    if pinSched.indices.contains(index) { //TODO: Условия для мистера SwiftUI который почему то после GroupSched -> nil хочет отрисовать DayView
                        LessonsView(lessons: daySched[index], pinned: $pinSched[index])
                            .frame(height: 100)
                    }
                }
            }
            .listStyle(.carousel)

        }
    }
}
