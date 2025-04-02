//
//  Parser.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 31.03.2024.
//

import Foundation
import SwiftSoup

func SSU_getFacultiesUri(completion: @escaping ([Faculty]) -> Void) {
    guard let url = URL(string: "https://www.old.sgu.ru/schedule") else {
        completion([])
        return
    }
    
    let task = URLSession.shared.dataTask(with: url) { data, _, error in
        guard let _ = data else {
            print("No data received")
            completion([])
            return
        }
        
        do {
            let facsPage: Document = try SwiftSoup.parse(String(contentsOf: url))
            var faculties : [Faculty] = []
            
            guard let body = facsPage.body() else {
                completion([])
                return
            }
            
            let dirtyFacs = try body.getElementsByClass("panes_item panes_item__type_group").first()!
            let facs = try dirtyFacs.getElementsByTag("li")
            for fac in facs {
                let nameFac = try fac.text()
                let uriFac = try fac.child(0).attr("href")
                faculties.append(Faculty(name: nameFac, uri: uriFac))
            }
            completion(faculties)
        }
        catch {
            print("Error parsing facultiesUri: \(error)")
            completion([])
        }
    }
    task.resume()
}

func SSU_getGroupsUri(uri : String, completion: @escaping ([Group]) -> Void) {
    var groups : [Group] = []
    guard let url = URL(string: "https://www.old.sgu.ru\(uri)") else {
        completion([])
        return
    }
    print("https://www.old.sgu.ru\(uri)")
    let task = URLSession.shared.dataTask(with: url) { data, _, error in
        guard let _ = data else {
            print("No data received")
            completion([])
            return
        }
        
        do {
            let facPage: Document = try SwiftSoup.parse(String(contentsOf: url))
            guard let bodyFac = facPage.body() else {
                completion([])
                return
            }
            let dirtGroups = try bodyFac.select(".course.form-wrapper > .fieldset-wrapper > a")
            for grp in dirtGroups {
                groups.append(Group(name: try grp.text(), uri: try grp.attr("href")))
            }
            
            completion(groups)
        }
        catch {
            print("Error parsing GroupsUri: \(error)")
            completion([])
        }
    }
    task.resume()
}

func SSU_getSchedule(uri: String, completion: @escaping (GroupSched) -> Void) {
    let scheduleOfGroup = GroupSched(university: "",
                                     faculty: "",
                                     group: "",
                                     date_read: "",
                                     schedule: [],
                                     pinSchedule: [])

    guard let url = URL(string: "https://www.old.sgu.ru/\(uri)") else {
        completion(scheduleOfGroup)
        return
    }
    
    print("https://www.old.sgu.ru/\(uri)")
    
    let task = URLSession.shared.dataTask(with: url) { data, _, error in
        guard let data = data else {
            print("No data received")
            completion(scheduleOfGroup)
            return
        }
        
        do {
            let doc: Document = try SwiftSoup.parse(String(decoding: data, as: UTF8.self))
            let groupSched = SSU_parseSched(doc: doc)
            completion(groupSched)
        }
        catch {
            print("Error parsing HTML: \(error)")
            completion(scheduleOfGroup)
        }
    }
    task.resume()
}

func SSU_parseSched(doc: Document) -> GroupSched {
    let scheduleOfGroup = GroupSched(university: "",
                                     faculty: "",
                                     group: "",
                                     date_read: "",
                                     schedule: [],
                                     pinSchedule: [])
    do {
        guard let body = doc.body() else {
            return scheduleOfGroup
        }
        
        let title = try doc.getElementsByTag("title").text().split(separator: " | ") //Распарсили заголовок
        if title.count >= 2 { //защита от попадания не на ту страничку
            scheduleOfGroup.group = String(title[0]) //на группу
            scheduleOfGroup.university = String(title[1]) //и название университета
            //Получили название факультета по определенному месту
            if try (body.select(".breadcrumbs > ul > li > a[href]").count >= 2) {
                scheduleOfGroup.faculty = try body.select(".breadcrumbs > ul > li > a[href]")[1].text()
            }
            else {
                scheduleOfGroup.faculty = ""
            }
        }
        else {
            return scheduleOfGroup
        }
        
        let daysRows : Elements
        if let sched = try body.select("table#schedule").first() {//Получили таблицу расписания
            daysRows = try sched.getElementsByTag("tr") //Достали из нее массив строк расписания (1 строка - первые пары всех дней...)
            
        }
        else {
            return scheduleOfGroup
        }
        
        for dirtyRow in daysRows { //Грязная строка не содержит только уроки, а содержит еще доп инфу
            if (try dirtyRow.getElementsByTag("td").isEmpty()) { //если это строка с именами дней, то просто создадим массивы уроков
                for _ in 0..<7 {
                    scheduleOfGroup.schedule.append([])
                    scheduleOfGroup.pinSchedule.append([])
                }
            }
            else { //иначе если это строка уроков
                let row = try dirtyRow.getElementsByTag("td") //иначе распарсиваем строку на чистый массив пар (первых например)
                let times = try dirtyRow.getElementsByTag("th").text().split(separator: " ") //также парсим время пары
                for day in row.indices { //проходим по индексированному массиву пар
                    //смотрим какие пары могут быть i-той парой, например если две пары в одно и то же время (чис/знам, 1,2,3 подгруппа)
                    let lessons = try row[day].getElementsByClass("l") //получаем этот массив пар "в один день, в одно время"
                    var simLessons : [Lesson] = [] //структура в которую будем грузить эти пары
                    for lesson in lessons { //для каждого такого массива пар преобразуем пару в структурированную
                        //и записываем ее в структуру "пары в одно время"
                        let parityText = try lesson.getElementsByClass("l-pr-r").text()
                        let parity = parityText.isEmpty ? [:] : ( parityText == "чис." ? [true : "чис."] : [false : "знам."]) 
                        var teacherOrGroup = ""
                        if (try lesson.getElementsByClass("l-tn").text() != "") {
                            //Необходимо для учеников ставить учителя
                            teacherOrGroup = try lesson.getElementsByClass("l-tn").text()
                        }
                        else {
                            //А для учителей ставить группы в поле "учитель"
                            teacherOrGroup = try lesson.getElementsByClass("l-g").text()
                        }

                        simLessons.append(Lesson(timeStart: Lesson.parseTimeInterval(from: String(times[0])), //Lesson.parseTime(String(times[0])),
                                                 timeEnd: Lesson.parseTimeInterval(from: String(times[1])), //Lesson.parseTime(String(times[1]))
                                                 type: try lesson.getElementsByClass("l-pr-t").text(),
                                                 subgroup: try lesson.getElementsByClass("l-pr-g").text(),
                                                 parity: parity,
                                                 name: try lesson.getElementsByClass("l-dn").text(),
                                                 teacher: teacherOrGroup,
                                                 place: try lesson.getElementsByClass("l-p").text()))
                        
                    }
                    scheduleOfGroup.pinSchedule[day].append([true:0, false:0]) //Ставится индекс пары, которая в текущую неделю закреплена
                    if (lessons.isEmpty()) {
                        scheduleOfGroup.schedule[day].append([Lesson(timeStart: Lesson.parseTimeInterval(from: String(times[0])), //Lesson.parseTime(String(times[0]))
                                                                     timeEnd: Lesson.parseTimeInterval(from: String(times[1])), //Lesson.parseTime(String(times[1]))
                                                                     type: "",
                                                                     subgroup: "",
                                                                     parity: [:],
                                                                     name: "Пары нет",
                                                                     teacher: "",
                                                                     place: "")])
                    }
                    else {
                        scheduleOfGroup.schedule[day].append(simLessons) //записываем в пару в массив "пары в этот день"
                    }
                }
            }
        }
        scheduleOfGroup.pinSchedule[6].append([true:0, false:0])
        scheduleOfGroup.schedule[6] = ([[Lesson(timeStart: 0/*Lesson.parseTime(String("00:00"))*/, timeEnd: 86340 /*Lesson.parseTime(String("23:59"))*/, type: "", subgroup: "", parity: [:], name: "Биг Чиллинг!", teacher: "", place: "")]])
    }
    catch {
        print("ERR")
        return(scheduleOfGroup)
    }
    
    scheduleOfGroup.date_read = Date().formatted() //гарантия того что парсинг прошел успешно - добавление даты парсинга
    
    //    DEBUG=======================================
    //    print(scheduleOfGroup.universities)
    //    print(scheduleOfGroup.faculty)
    //    print(scheduleOfGroup.group)
    //
    //    for lessons in scheduleOfGroup.schedule[0] {
    //        print("newLESSON")
    //        for lesson in lessons {
    //            print(lesson.name)
    //        }
    //    }
    //    DEBUG=======================================
    
    return scheduleOfGroup
}


func SSU_getTeachersUri(completion: @escaping ([Teacher]) -> Void) {
    guard let url = URL(string: "https://old.sgu.ru/schedule/teacher/search") else {
        completion([])
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = "js=1&".data(using: .utf8)
    
    let task = URLSession.shared.dataTask(with: request) { data, _, error in
        guard let data = data else {
            print("No data received")
            completion([])
            return
        }
        do {
            let teachers = try JSONDecoder().decode([Teacher].self, from: data)
            completion(teachers)
        }
        catch {
            print("Error parsing HTML: \(error)")
            completion([])
        }
    }
    task.resume()
}
