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
    @Binding var pinSched : [[Bool:UUID]]

    var body: some View {
        VStack {
            Text(day)
            List {// ScrollView { // TODO: Дает красивую анимацию сворачивания, но не подгибается красиво при скроллинге как это делает лист
                //LazyVStack {
                    ForEach (daySched.indices, id: \.self) { index in
                        if pinSched.indices.contains(index) { //TODO: Условия для мистера SwiftUI который почему то после GroupSched -> nil хочет отрисовать DayView
                            LessonsView(lessons: daySched[index], pinned: $pinSched[index])
                            
                        }
                    }
                //}
            }
            .listStyle(.carousel)

        }
    }
}
