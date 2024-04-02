//
//  SchedPickerView.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 31.03.2024.
//

import SwiftUI

struct SchedPickerView: View {
    @ObservedObject var Sched = SchedModel() //TODO: СОЗДАЕТ БАГИ С ПОСТОЯННОЙ РЕФОРМАЦИЕЙ ПИНОВ!
    @State private var Faculties : [Faculty] = []
    @State private var selectedFaculty = 0
    @State private var selectedGroup = 0
    
    var body: some View {
        NavigationStack {
            VStack (spacing: 40) {
                Text("Скачать расписание")
                Button(action: {
                    getFacultGroups { fac in
                        DispatchQueue.main.async {
                            self.Faculties = fac
                        }
                    }
                }) {
                    Text("Загрузить факультеты и группы")
                        .foregroundStyle(.white)
                }.padding().background(.gray)
                Button(action: {
                    Sched.clearData()
                }) {
                    Text("Очистить расписание")
                        .foregroundStyle(.white)
                }.padding().background(.gray)
                if !Faculties.isEmpty {
                    Picker(selection: $selectedFaculty, label: Text("Выберите факультет").foregroundStyle(.white)) {
                        ForEach(0..<Faculties.count, id: \.self) { index in
                            Text(Faculties[index].name).tag(index)
                                //.foregroundStyle(.white)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    .padding().background(.lines)
                    
                    
                    Picker(selection: $selectedGroup, label: Text("Выберите группу").foregroundStyle(.white)) {
                        ForEach(0..<Faculties[selectedFaculty].groups.count, id: \.self) { index in
                            Text(Faculties[selectedFaculty].groups[index].number).tag(index)
                                //.foregroundStyle()
                                //.background(.gray).ignoresSafeArea()
                        }
                    }
                    .pickerStyle(.navigationLink)
                    .padding().background(.lines)
                } else {
                    Text("Нет доступных факультетов и групп")
                }
                Button(action: {
                    if (!Faculties.isEmpty) {
                        Sched.getData(uri: Faculties[selectedFaculty].groups[selectedGroup].uri)
                    }
                }) {
                    Text("Загрузить выбранное расписание")
                        .foregroundStyle(.white)
                }.padding().background(.gray)
                
                Picker(selection: $Sched.currItem, label: Text("Выберите расписание").foregroundStyle(.white)) {
                    ForEach(Sched.items.indices, id: \.self) { index in
                        HStack {
                            Text("\(Sched.items[index].faculty) \(Sched.items[index].group)")
                        }
                    }
                }
                .pickerStyle(.navigationLink)
                .padding().background(.lines)
                

                              
            }.padding(40)
        }
    }
}

#Preview {
    SchedPickerView()
}
