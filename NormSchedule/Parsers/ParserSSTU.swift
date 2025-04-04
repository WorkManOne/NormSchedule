//
//  Parser.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 31.03.2024.
//

import Foundation
import SwiftSoup

@MainActor
class UniversityParser {
    static let shared = UniversityParser()
}

func SSTU_getFacultiesUri(completion: @escaping ([Faculty]) -> Void) {
    guard let url = URL(string: "https://rasp.sstu.ru/") else {
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
            
            let facs = try body.getElementsByClass("institute")
            for fac in facs {
                let nameFac = try fac.text()
                let idFac = try fac.attr("aria-controls")
                faculties.append(Faculty(name: nameFac, uri: idFac))
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

func SSTU_getGroupsUri(uri : String, completion: @escaping ([Group]) -> Void) {
    var groups : [Group] = []
    guard let url = URL(string: "https://rasp.sstu.ru/") else {
        completion([])
        return
    }
    //print("https://rasp.sstu.ru/\(uri)")
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
            let dirtGroups = try bodyFac.select("#\(uri) .col-auto.group a")
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

func SSTU_getSchedule(uri: String, completion: @escaping (GroupSched) -> Void) {
    let scheduleOfGroup = GroupSched(university: "",
                                     faculty: "",
                                     group: "",
                                     date_read: "",
                                     schedule: [],
                                     pinSchedule: [])

    guard let url = URL(string: "https://rasp.sstu.ru/\(uri)") else {
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
            let groupSched = SSTU_parseSched(doc: doc)
            completion(groupSched)
        }
        catch {
            print("Error parsing HTML: \(error)")
            completion(scheduleOfGroup)
        }
    }
    task.resume()
}

func SSTU_parseSched(doc: Document) -> GroupSched {
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
        
        let title = try doc.getElementsByTag("title").text().split(separator: " ") //Распарсили заголовок
        //print(title)
        scheduleOfGroup.group = String(title[2]) //на группу
        scheduleOfGroup.university = String(title[3]) //и название университета
        
        for _ in 0..<7 {
            scheduleOfGroup.schedule.append([])
            scheduleOfGroup.pinSchedule.append([])
        }
        
        let weeks = try body.getElementsByClass("week")
        
        var weekNum = 0
        
        for week in weeks { //Грязная строка не содержит только уроки, а содержит еще доп инфу
            weekNum += 1
            if weekNum > 2 { break }
            
            //var weekSched : [[Lesson]] = []
            let dirtyDays = try week.getElementsByClass("day") //содержат столбец (первый) со временем пар
            
            // Извлечение времени уроков
            var times = [[String]]()
            let timeColumn = try dirtyDays.first()!.getElementsByClass("day-lesson") //TODO: ОПАСНОСТЬ!
            for lesson in timeColumn {
                //необходимо грамотно избавиться от номера пары
                let fullHtml = try lesson.html()
                if let spanHtml = try lesson.select("span").first()?.outerHtml() {
                    let timeHtml = fullHtml.replacingOccurrences(of: spanHtml, with: "")
                    let timeRange = try SwiftSoup.parse(timeHtml).text().split(separator: " - ").map { String($0) }
                    times.append(timeRange)
                }
            }
            
            
            let days = dirtyDays.dropFirst() //убрали столбец времен
            for (dayIndex, day) in days.enumerated() {
                var daySched : [[Lesson]] = []
                let lessons = try day.getElementsByClass("day-lesson")
                for (lessonIndex, lesson) in lessons.enumerated() {
                    // Извлечение места проведения урока
                    let lessonRooms = try lesson.getElementsByClass("lesson-room")
                    let lessonTeacher = try lesson.getElementsByClass("lesson-teacher")
                    
                    var teachers = [String]()
                    var rooms = [String]()
                    var subGroups = [String]()

                    if lessonTeacher.count == 0 {
                        for i in stride(from: 1, to: lessonRooms.count, by: 1) {
                            let subGroupDetails = try lessonRooms[i].text().split(separator: ": ")
                            print(subGroupDetails)
                            subGroups.append(subGroupDetails.count > 0 ? String(subGroupDetails[0]) : "")
                            teachers.append(subGroupDetails.count > 1 ? String(subGroupDetails[1]) : "")
                            rooms.append(try lessonRooms.first()?.text() ?? "")
                        }
                    } else {
                        if lessonRooms.count == 2 {
                            teachers.append(try lessonTeacher[0].text())
                            subGroups.append(try lessonRooms[1].text())
                            rooms.append(try lessonRooms[0].text())
                        }
                        else {
                            for i in stride(from: 0, to: lessonRooms.count, by: 2) {
                                teachers.append(try lessonTeacher[i/2].text())
                                subGroups.append(try lessonRooms[i].text())
                                rooms.append(try lessonRooms[i+1].text())
                            }
                        }
                    }
                    // Извлечение названия урока
                    var lessonName = try lesson.getElementsByClass("lesson-name").text()
                    if lessonName.isEmpty { lessonName = "Пары нет" }
                    // Извлечение типа урока
                    let lessonType = try lesson.getElementsByClass("lesson-type").text()
                    // Извлечение информации о преподавателе
                    var simLessons = [Lesson]()
                    for (index, subGroup) in subGroups.enumerated() {
                        simLessons.append(Lesson(timeStart: Lesson.parseTimeInterval(from: times[lessonIndex][0]), //Lesson.parseTime(times[lessonIndex][0]),
                                                 timeEnd: Lesson.parseTimeInterval(from: times[lessonIndex][1]), //Lesson.parseTime(times[lessonIndex][1]),
                                                 type: lessonType,
                                                 subgroup: subGroup,
                                                 parity: weekNum == 1 ? [true : "Нед. 1"] : [false : "Нед. 2"],
                                                 name: lessonName,
                                                 teacher: teachers[index],
                                                 place: rooms[index]))
                    }
                    if simLessons.isEmpty {
                        simLessons.append(Lesson(timeStart: Lesson.parseTimeInterval(from: times[lessonIndex][0]), //Lesson.parseTime(times[lessonIndex][0]),
                                                 timeEnd: Lesson.parseTimeInterval(from: times[lessonIndex][1]), //Lesson.parseTime(times[lessonIndex][1]),
                                                 type: "",
                                                 subgroup: "",
                                                 parity: weekNum == 1 ? [true : "Нед. 1"] : [false : "Нед. 2"],
                                                 name: "Пары нет",
                                                 teacher: "",
                                                 place: ""))
                    }
                    daySched.append(simLessons)
                    //print("Время: \(times[lessonIndex][0]) - \(times[lessonIndex][1]), Аудитории: \(roomDetails.joined(separator: ", ")), Название урока: \(lessonName), Тип: \(lessonType), Преподаватель: \(lessonTeacher)")
                }
                if scheduleOfGroup.schedule[dayIndex].count < daySched.count {
                    for _ in 0..<daySched.count - scheduleOfGroup.schedule[dayIndex].count  {
                        scheduleOfGroup.schedule[dayIndex].append([])
                    }
                }
                for (lessonIndex, lesson) in daySched.enumerated() {
                    scheduleOfGroup.schedule[dayIndex][lessonIndex].append(contentsOf: lesson)
                }
                
            }
        }
        for (dayIndex, day) in scheduleOfGroup.schedule.enumerated() {
            for _ in day {
                scheduleOfGroup.pinSchedule[dayIndex].append([true:0, false:0])
            }
        }

        scheduleOfGroup.pinSchedule[6].append([true:0, false:0])
        scheduleOfGroup.schedule[6] = ([[Lesson(timeStart: 0/*Lesson.parseTime(String("00:00"))*/, timeEnd: 86340/*Lesson.parseTime(String("23:59"))*/, type: "", subgroup: "", parity: [:], name: "Биг Чиллинг!", teacher: "", place: "")]])
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

func SSTU_getTeachersUri(completion: @escaping ([Teacher]) -> Void) {
    
    guard let url = URL(string: "https://rasp.sstu.ru/rasp/teachers") else {
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
            let doc = try SwiftSoup.parse(String(decoding: data, as: UTF8.self))
            guard let body = doc.body() else {
                completion([])
                return
            }
            var teachers = [Teacher]()
            let dirtyTeachers = try body.select(".list-teacher > .row a")
            for teacher in dirtyTeachers {
                teachers.append(Teacher(name: try teacher.text(), uri: try teacher.attr("href")))
            }
            completion(teachers)
        }
        catch {
            print("Error parsing HTML: \(error)")
            completion([])
        }
    }
    task.resume()
}
