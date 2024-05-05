//
//  SchedModel.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 14.03.2024.
//

import Foundation

struct Lesson : Identifiable, Codable, Hashable {
    var id = UUID()
    
    enum CodingKeys: String, CodingKey {
        case timeStart, timeEnd, type, subgroup, name, teacher, place, parity
    }
    
    var timeStart : String
    var timeEnd : String
    var type : String
    var subgroup : String
    var parity : [Bool:String]
    var name : String
    var teacher : String
    var place : String
}

struct GroupSched : Codable {
    init(university: String, faculty: String, group: String, date_read: String, schedule: [[[Lesson]]], pinSchedule: [[[Bool:Int]]], id: UUID? = nil) {
        self.university = university
        self.faculty = faculty
        self.group = group
        self.id = UUID(uuidString: "\(university)\(faculty)\(group)") ?? UUID()
        self.schedule = schedule
        self.pinSchedule = pinSchedule
        self.date_read = date_read
    }
    var university : String
    var faculty : String
    var group : String
    var date_read : String
    var schedule : [[[Lesson]]]
    //    var pinSchedule : [[Int]] =   [ [[true:0, false:0],[true:0, false:0],[true:0, false:0],[true:2, false:0],[true:0, false:0],[true:0, false:0],[true:0, false:0],[true:0, false:0],[true:0, false:0]], [1,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0] ]
    var pinSchedule : [[[Bool:Int]]]
    var id : UUID
}
class SettingsManager: Decodable, Encodable, ObservableObject {
    @Published var isEvenWeek: Int {
        didSet {
            let defaults = UserDefaults.standard
            let encoder = JSONEncoder()
            if let settings = try? encoder.encode(self) {
                defaults.set(settings, forKey: "settings")
            }
        }
    }
    
    init() {
        let defaults = UserDefaults.standard
        if let data = defaults.object(forKey: "settings") as? Data {
            let decoder = JSONDecoder()
            if let settings = try? decoder.decode(SettingsManager.self, from: data) {
                self.isEvenWeek = settings.isEvenWeek
                return
            }
            else {
                self.isEvenWeek = 0
            }
        }
        else {
            self.isEvenWeek = 0
        }
        
    }
    
    private enum CodingKeys: String, CodingKey {
            case isEvenWeek
    }
    
    required init(from decoder:Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            isEvenWeek = try values.decode(Int.self, forKey: .isEvenWeek)
    }
    public func encode(to encoder: Encoder) throws {
            var values = encoder.container(keyedBy: CodingKeys.self)
            try values.encode(isEvenWeek, forKey: .isEvenWeek)
    }
    
    
}

class SchedModel : ObservableObject, Encodable, Decodable {
    private enum CodingKeys: String, CodingKey {
            case items, currDay, currItem
    }
    
    required init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        items = try values.decode([GroupSched].self, forKey: .items)
        currItem = try values.decode(Int.self, forKey: .currItem)
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(items, forKey: .items)
        try values.encode(currItem, forKey: .currItem)
    }
    
    //let days = ["Пн","Вт","Ср","Чт","Пт","Сб","Вс"]
    //var id = UUID()
    //@Published var isEvenWeek: Bool
    
    @Published var currDay = "Пн"
    @Published var currItem = 0 {
        didSet {
            print("changed shed, \(currItem)")
            let defaults = UserDefaults.standard
            let encoder = JSONEncoder()
            if let Sched = try? encoder.encode(self) {
                defaults.set(Sched, forKey: "Sched")
            }
        }
    }
    @Published var items: [GroupSched] = [] {
        didSet {
            let defaults = UserDefaults.standard
            let encoder = JSONEncoder()
            if let Sched = try? encoder.encode(self) {
                defaults.set(Sched, forKey: "Sched")
            }
        }
    }
    
    init() {
        let defaults = UserDefaults.standard
        if let data = defaults.object(forKey: "Sched") as? Data,
           let Sched = try? JSONDecoder().decode(SchedModel.self, from: data) {
            self.items = Sched.items
            //self.currDay = Sched.currDay
            self.currItem = Sched.currItem //Двойная инициализация вызывается из-за двух методов init?
            //print("reform in init")
            pinnedReform()
        }
        else {
            print("Bad Sched init")
            self.items = []
        }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru-RU")
        dateFormatter.setLocalizedDateFormatFromTemplate("EEE")
        self.currDay = dateFormatter.string(from: Date())
    }
    
    func clearData() {
        items = []
    }
    
    func getData(id: Int, uri: String) {
        getGroup(id: id, uri: uri) { groupSched in
            DispatchQueue.main.async {
                self.items.append(groupSched)
                self.currItem = self.items.count - 1
                self.pinnedReform()
            }
        }
    }
    /*
    func getDataDeprecated() {
        do {
            let path = Bundle.main.url(forResource: "sched", withExtension: "json")!
            let data = try Data(contentsOf: path)
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            var formalizedSchedule : [[[Lesson]]] = []
            var pinnedInit : [[Int]] = []
            guard let uni = json as? [String:Any] else {return}
            guard let uniName = uni["universities"] as? String  else {return}
            guard let fac = uni["faculty"] as? String  else {return}
            guard let group = uni["groups"] as? String  else {return}
            guard let date = uni["date_read"] as? String  else {return}
            guard let schedule = uni["schedule"] as? [String:[[String:String]]] else {return}
            //сортировка
            let daysOrder = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
            var orderedSchedule: [[[String: String]]] = []

            for day in daysOrder {
                if let lessons = schedule[day] {
                    orderedSchedule.append(lessons)
                }
            }
            
            for lessons in orderedSchedule {
                var formalizedLessons : [[Lesson]] = []
                var similarLessons : [Lesson] = []
                pinnedInit.append([])
                
                for i in 0..<lessons.count {
                    // Первый урок всегда добавляем в список похожих
                    if similarLessons.isEmpty {
                        similarLessons.append(Lesson(timeStart: lessons[i]["time"] ?? "", timeEnd: lessons[i]["time"] ?? "", type: lessons[i]["type"] ?? "", subgroup: lessons[i]["subgroup"] ?? "", parity: lessons[i]["chis/znam"] ?? "", name: lessons[i]["name"] ?? "", teacher: lessons[i]["teacher"] ?? "", place: lessons[i]["place"] ?? ""))
                        
                    } else {
                        // Проверяем сходство текущего урока с последним добавленным в список
                        if lessons[i]["time"] == similarLessons.last!.timeStart {
                            // Если уроки сходятся, добавляем текущий урок в список похожих
                            similarLessons.append(Lesson(timeStart: lessons[i]["time"] ?? "", timeEnd: lessons[i]["time"] ?? "", type: lessons[i]["type"] ?? "", subgroup: lessons[i]["subgroup"] ?? "", parity: lessons[i]["chis/znam"] ?? "", name: lessons[i]["name"] ?? "", teacher: lessons[i]["teacher"] ?? "", place: lessons[i]["place"] ?? ""))
                        } else {
                            // Если уроки не сходятся, завершаем текущий список похожих и начинаем новый
                            formalizedLessons.append(similarLessons)
                            pinnedInit[orderedSchedule.firstIndex(of: lessons)!].append(0)
                            similarLessons = [Lesson(timeStart: lessons[i]["time"] ?? "", timeEnd: lessons[i]["time"] ?? "", type: lessons[i]["type"] ?? "", subgroup: lessons[i]["subgroup"] ?? "", parity: lessons[i]["chis/znam"] ?? "", name: lessons[i]["name"] ?? "", teacher: lessons[i]["teacher"] ?? "", place: lessons[i]["place"] ?? "")]
                        }
                    }
                }
                // Добавляем последний список похожих уроков в формализованные уроки
                if !similarLessons.isEmpty {
                    formalizedLessons.append(similarLessons)
                    pinnedInit[orderedSchedule.firstIndex(of: lessons)!].append(0)
                }
                formalizedSchedule.append(formalizedLessons)
            }
            formalizedSchedule.append([[Lesson(timeStart: "Целый день", timeEnd: "Целую ночь", type: "", subgroup: "", parity: "", name: "Биг Чиллинг!", teacher: "", place: "")]]) //Добавили воскресенье!
            pinnedInit.append([]) //Добавили воскресенье!
            pinnedInit[6].append(0) //Добавили воскресенье!
            //Если вдруг будет расширение то надо будет решить с этим вопрос, а пока пусть контейнер стирается
            items.removeAll()
            items.append(GroupSched(university: uniName, faculty: fac, group: group, date_read: date, schedule: formalizedSchedule, pinSchedule: pinnedInit))
            pinnedReform()
        }
        catch {
            print("Bad file")
        }
    }
    */
    func pinnedReform() {
        if items.isEmpty { return }
        if currItem >= items.count { currItem = 0; return} //TODO: костыль для избежания ошибки
        let settingsManager = SettingsManager()
        //Добавить реформ всех расписаний?? Или сделать так чтобы они реформились когда их загружаешь
        for day in 0..<items[currItem].schedule.count { //А если дня не будет?
            for lessons in 0..<items[currItem].schedule[day].count {
                var needReformTrue = true
                var needReformFalse = true
                let pinned = items[currItem].pinSchedule[day][lessons]
                print(items[currItem].schedule[day][lessons], pinned[true] ?? 0)
                if items[currItem].schedule[day][lessons].isEmpty { return }
                if (items[currItem].schedule[day][lessons][pinned[true] ?? 0].parity.keys.contains(true)) {
                    needReformTrue = false
                }
                if (items[currItem].schedule[day][lessons][pinned[false] ?? 0].parity.keys.contains(false)) {
                    needReformFalse = false
                }
                
                if (needReformTrue || needReformFalse) {
                    for lesson in 0..<items[currItem].schedule[day][lessons].count {
                        if (needReformTrue && items[currItem].schedule[day][lessons][lesson].parity.keys.contains(true)) {
                                items[currItem].pinSchedule[day][lessons][true] = lesson
                                needReformTrue = false
                        }
                        if (needReformFalse && items[currItem].schedule[day][lessons][lesson].parity.keys.contains(false)) {
                            items[currItem].pinSchedule[day][lessons][false] = lesson
                            needReformFalse = false
                        }
                        if (!needReformTrue && !needReformFalse) { break }
                    }
                }
            }
        }
        //objectWillChange.send()
        print("reformed: now - \(settingsManager.isEvenWeek)")
        
    }
    func recalcCurrDay() {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru-RU")
        dateFormatter.setLocalizedDateFormatFromTemplate("EEE")
        self.currDay = dateFormatter.string(from: Date())
    }
}


