//
//  Parser.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 31.03.2024.
//

import Foundation
import SwiftSoup

struct Group {
    var number : String
    var uri : String
}

struct Faculty {
    var name : String
    var uri : String
    var groups : [Group]
}


func getFacultGroups(completion: @escaping ([Faculty]) -> Void) {
    guard let url = URL(string: "https://www.sgu.ru/schedule") else {
        completion([])
        return
    }
    
    let task = URLSession.shared.dataTask(with: url) { data, _, error in
        guard let data = data else {
            print("No data received")
            completion([])
            return
        }
        
        do {
            let facsPage: Document = try SwiftSoup.parse(String(contentsOf: url))
            let faculties = parseFaculties(doc: facsPage)
            completion(faculties)
        }
        catch {
            print("Error parsing HTML: \(error)")
            completion([])
        }
    }
    task.resume()
}

func parseFaculties(doc : Document) -> [Faculty] {
    var faculties : [Faculty] = []
    let faculty = Faculty(name: "", uri: "", groups: [])
    
    do {
        guard let body = doc.body() else {
            return []
        }
        
        let dirtyFacs = try body.getElementsByClass("panes_item panes_item__type_group").first()!
        let facs = try dirtyFacs.getElementsByTag("li")
        for fac in facs {
            faculties.append(Faculty(name: try fac.text(), uri: try fac.child(0).attr("href"), groups: []))
        }
        
        for fac in faculties.indices {
            guard let url = URL(string: "https://www.sgu.ru\(faculties[fac].uri)") else {
                return []
            }
            let facPage: Document = try SwiftSoup.parse(String(contentsOf: url))
            guard let bodyFac = facPage.body() else {
                return []
            }
            let dirtGroups = try bodyFac.select(".course.form-wrapper > .fieldset-wrapper > a")
            for grp in dirtGroups {
                faculties[fac].groups.append(Group(number: try grp.text(), uri: try grp.attr("href")))
            }
        }
    }
    catch {
        print("ERR")
        return []
    }
    return faculties
}


func getGroup(urlString: String, completion: @escaping (GroupSched) -> Void) {
    let scheduleOfGroup = GroupSched(university: "",
                                     faculty: "",
                                     group: "",
                                     date_read: "",
                                     schedule: [[],[],[],[],[],[],[]],
                                     pinSchedule: [[],[],[],[],[],[],[]])
    
    guard let url = URL(string: urlString) else {
        completion(scheduleOfGroup)
        return
    }
    
    let task = URLSession.shared.dataTask(with: url) { data, _, error in
        guard let data = data else {
            print("No data received")
            completion(scheduleOfGroup)
            return
        }
        
        do {
            let doc: Document = try SwiftSoup.parse(String(decoding: data, as: UTF8.self))
            let groupSched = parseDocument(doc: doc)
            completion(groupSched)
        }
        catch {
            print("Error parsing HTML: \(error)")
            completion(scheduleOfGroup)
        }
    }
    task.resume()
}

func parseDocument(doc: Document) -> GroupSched {
    var scheduleOfGroup = GroupSched(university: "",
                                     faculty: "",
                                     group: "",
                                     date_read: "",
                                     schedule: [[],[],[],[],[],[],[]],
                                     pinSchedule: [[],[],[],[],[],[],[]])
    do {
        guard let body = doc.body() else {
            return scheduleOfGroup
        }
        
        let title = try doc.getElementsByTag("title").text().split(separator: " | ") //Распарсили заголовок
        if try (title.count >= 2 && body.select(".breadcrumbs > ul > li > a[href]").count >= 2) { //защита от попадания не на ту страничку
            scheduleOfGroup.group = String(title[0]) //на группу
            scheduleOfGroup.university = String(title[1]) //и название университета
            //Получили название факультета по определенному месту
            scheduleOfGroup.faculty = try body.select(".breadcrumbs > ul > li > a[href]")[1].text()
        }
        else {
            return scheduleOfGroup
        }
        
        let sched = try body.select("table#schedule").first()//Получили таблицу расписания TODO: Опасное место!
        let daysRows = try sched!.getElementsByTag("tr") //Достали из нее массив строк расписания (1 строка - первые пары всех дней...)
        for dirtyRow in daysRows { //Грязная строка не содержит только уроки, а содержит еще доп инфу
            if (try dirtyRow.getElementsByTag("td").isEmpty()) { //если это строка с именами дней, то просто создадим массивы уроков
                continue
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
                        simLessons.append(Lesson(timeStart: String(times[0]),
                                                 timeEnd: String(times[1]),
                                                 type: try lesson.getElementsByClass("l-pr-t").text(),
                                                 subgroup: try lesson.getElementsByClass("l-pr-g").text(),
                                                 parity: try lesson.getElementsByClass("l-pr-r").text(),
                                                 name: try lesson.getElementsByClass("l-dn").text(),
                                                 teacher: try lesson.getElementsByClass("l-tn").text(),
                                                 place: try lesson.getElementsByClass("l-p").text()))
                        
                    }
                    scheduleOfGroup.pinSchedule[day].append(0)
                    if (lessons.isEmpty()) {
                        scheduleOfGroup.schedule[day].append([Lesson(timeStart: String(times[0]),
                                                                     timeEnd: String(times[1]),
                                                                     type: "",
                                                                     subgroup: "",
                                                                     parity: "",
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
        scheduleOfGroup.pinSchedule[6].append(0)
        scheduleOfGroup.schedule[6] = ([[Lesson(timeStart: "Целый день", timeEnd: "Целую ночь", type: "", subgroup: "", parity: "", name: "Биг Чиллинг!", teacher: "", place: "")]])
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
//getGroup(url: "https://www.sgu.ru/schedule/knt/do/311")
