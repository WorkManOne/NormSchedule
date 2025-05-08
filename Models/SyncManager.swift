//
//  SyncManager.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 06.05.2025.
//

import Foundation

class SyncManager {
    static let shared = SyncManager()

    func syncAll(schedule: GroupSched?, parity: Int) {
        print("syncAll")
        WidgetDataManager().save(schedule: schedule, parity: parity)
        WCProvider.shared.update(schedule: schedule, parity: parity) //TODO: Работает так потому что работает через контекст
    }
}
