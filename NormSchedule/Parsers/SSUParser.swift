//
//  Parser.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 31.03.2024.
//

import Foundation
import SwiftSoup

final class SSUParser: UniversityParser {

    func getFaculties() async -> Result<[FacultyModel], ParserError> {
        do {
            guard let url = URL(string: "https://www.sgu.ru/schedule") else {
                return .failure(.invalidData)
            }
            let (data, _) = try await URLSession.shared.data(from: url)
            let htmlString = String(decoding: data, as: UTF8.self)

            let facsPage: Document = try SwiftSoup.parse(htmlString)
            var faculties : [FacultyModel] = []

            guard let body = facsPage.body() else {
                return .failure(.parsingFailed(reason: "Не удалось получить тело страницы"))
            }

            let facs = try body.getElementsByClass("accordion__wrap-title")

            for fac in facs {
                let nameFac = try fac.text()
                let uriFac = try fac.text()
                faculties.append(FacultyModel(name: nameFac, uri: uriFac))
            }
            return .success(faculties)
        } catch {
            return .failure(.parsingFailed(reason: error.localizedDescription))
    //            if let urlError = error as? URLError, urlError.code == .notConnectedToInternet {
    //                return .failure(.networkError) // Специфическая ошибка для отсутствия интернета
    //            }
    //
    //            // Если ошибка не связана с сетью, возвращаем общую ошибку с описанием
    //            return .failure(.parsingFailed(reason: error.localizedDescription))
        }
    }

    func getGroups(uri: String) async -> Result<[GroupModel], ParserError> {
        do {
            var groups : [GroupModel] = []
            guard let url = URL(string: "https://www.sgu.ru/schedule") else {
                return .failure(.invalidData)
            }

            let (data, _) = try await URLSession.shared.data(from: url)
            let htmlString = String(decoding: data, as: UTF8.self)

            let facsPage: Document = try SwiftSoup.parse(htmlString)
            guard let body = facsPage.body() else {
                return .failure(.parsingFailed(reason: "Не удалось получить тело страницы"))
            }

            let facultyHeaders = try body.select(".accordion__wrap-title")
            for header in facultyHeaders {
                let headerText = try header.select(".accordion__header").text().trimmingCharacters(in: .whitespacesAndNewlines)
                if headerText == uri {
                    if let content = try header.nextElementSibling() {
                        let links = try content.select(".schedule-number__item a")
                        for link in links {
                            let name = try link.text().trimmingCharacters(in: .whitespacesAndNewlines)
                            let href = try link.attr("href").trimmingCharacters(in: .whitespacesAndNewlines)
                            groups.append(GroupModel(name: name, uri: href))
                        }
                    }
                    break
                }
            }

            return .success(groups)
        } catch {
            return .failure(.parsingFailed(reason: error.localizedDescription))
        }
    }

    func getSchedule(uri: String) async -> Result<GroupSched, ParserError> {
        do {
            guard let url = URL(string: "https://www.sgu.ru\(uri)") else {
                return .failure(.invalidData)
            }
            let (data, _) = try await URLSession.shared.data(from: url)
            let htmlString = String(decoding: data, as: UTF8.self)
            let doc: Document = try SwiftSoup.parse(htmlString)
            let groupSched = parseSchedule(doc: doc)
            let parts = uri.split(separator: "/")
            if parts.count >= 4 {
                groupSched.faculty = String(parts[1]) + " " + String(parts[2])
                groupSched.group = String(parts[3])
            }
            return .success(groupSched)
        } catch {
            return .failure(.parsingFailed(reason: error.localizedDescription))
        }
    }

    func getTeachers() async -> Result<[TeacherModel], ParserError> {
        do {
            guard let url = URL(string: "https://old.sgu.ru/schedule/teacher/search") else {
                return .failure(.invalidData)
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = "js=1&".data(using: .utf8)
            let (data, _) = try await URLSession.shared.data(for: request)
            let teachers = try JSONDecoder().decode([TeacherModel].self, from: data)
            return .success(teachers)
        } catch {
            return .failure(.parsingFailed(reason: error.localizedDescription))
        }
    }

    func parseSchedule(doc: Document) -> GroupSched {
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
                scheduleOfGroup.group = try doc.getElementsByClass("schedule__title").first()?.text() ?? "" //на группу Временное решение вместо String(title[0])
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
            for _ in 0..<7 {
                scheduleOfGroup.schedule.append([])
                scheduleOfGroup.pinSchedule.append([])
            }
            for dirtyRow in daysRows { //Грязная строка не содержит только уроки, а содержит еще доп инфу
                if !(try dirtyRow.getElementsByTag("td").isEmpty()) { //это строка уроков
                    let row = try dirtyRow.getElementsByTag("td") //распарсиваем строку на чистый массив пар (первых например)
                    let times = try dirtyRow.getElementsByTag("th").text().split(separator: " ") //также парсим время пары
                    for day in row.indices { //проходим по индексированному массиву пар
                        //смотрим какие пары могут быть i-той парой, например если две пары в одно и то же время (чис/знам, 1,2,3 подгруппа)
                        let lessons = try row[day].getElementsByClass("schedule-table__lesson") //получаем этот массив пар "в один день, в одно время"
                        var simLessons : [Lesson] = [] //структура в которую будем грузить эти пары
                        for lesson in lessons { //для каждого такого массива пар преобразуем пару в структурированную
                            //и записываем ее в структуру "пары в одно время"
                            let parity1 = try lesson.getElementsByClass("lesson-prop__num").text()
                            let parity2 = try lesson.getElementsByClass("lesson-prop__denom").text()
                            let parityText = [parity1, parity2].first { !$0.isEmpty } ?? "" //Из-за нового обновления сайта, теперь каждая четность имеет свой класс
                            let parity = parityText.isEmpty ? [:] : ( parityText == "Ч" ? [true : "Ч"] : [false : "З"])
                            var teacherOrGroup = ""
                            if (try lesson.getElementsByClass("schedule-table__lesson-teacher").text() != "") {
                                //Необходимо для учеников ставить учителя
                                teacherOrGroup = try lesson.getElementsByClass("schedule-table__lesson-teacher").text()
                            }
                            else {
                                //А для учителей ставить группы в поле "учитель"
                                teacherOrGroup = try lesson.getElementsByClass("schedule-table__lesson-group").text()
                            }
                            let practice = try lesson.getElementsByClass("lesson-prop__practice").text()
                            let lecture = try lesson.getElementsByClass("lesson-prop__lecture").text()
                            let lab = try lesson.getElementsByClass("lesson-prop__laboratory").text()
                            let type = [practice, lecture, lab].first { !$0.isEmpty }?.lowercased() ?? "" //Из-за нового обновления сайта, теперь каждый тип имеет свой класс

                            simLessons.append(Lesson(timeStart: Lesson.parseTimeInterval(from: String(times[0])), //Lesson.parseTime(String(times[0])),
                                                     timeEnd: Lesson.parseTimeInterval(from: String(times[1])), //Lesson.parseTime(String(times[1]))
                                                     type: type,
                                                     subgroup: try lesson.getElementsByClass("schedule-table__lesson-uncertain").text(),
                                                     parity: parity,
                                                     name: try lesson.getElementsByClass("schedule-table__lesson-name").text(),
                                                     teacher: teacherOrGroup,
                                                     place: try lesson.getElementsByClass("schedule-table__lesson-room").text()))

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
        scheduleOfGroup.pinnedReform()
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

}
