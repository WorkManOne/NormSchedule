//
//  SyncManager.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 06.05.2025.
//

import Foundation

class SyncManager {
    static let shared = SyncManager()

    func syncAll(schedule: GroupSched?, parity: Int) { //TODO: нельзя просто пихать только один параметр потому что контекст всегда синхронит ПОСЛЕДНИЕ данные
        print("syncAll")
        //if let schedule = schedule {
            WCProvider.shared.updateSchedule(schedule: schedule)
            WidgetDataManager().save(schedule: schedule)
        //}
        //if let parity = parity {
            WCProvider.shared.updateParity(parity: parity)
            WidgetDataManager().save(parity: parity)
        //}
    }
}
