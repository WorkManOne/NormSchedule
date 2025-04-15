//
//  WCProvider.swift
//  NormScheduleCompanion Watch App
//
//  Created by Кирилл Архипов on 03.03.2025.
//

import Foundation
import WatchConnectivity

class WCProvider: NSObject, WCSessionDelegate, ObservableObject {

    static let shared = WCProvider()

    private var session: WCSession?

    @Published var receivedSchedule: GroupSched = GroupSched(university: "", faculty: "", group: "", date_read: "", schedule: [], pinSchedule: [])
    {
        willSet {
            saveSchedule(newValue)
        }
    }
    private override init() {
        super.init()
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
            print("Сессия активирована")
        }
        loadSchedule()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Session activation failed with error: \(error.localizedDescription)")
        } else {
            print("Session activated with state: \(activationState.rawValue)")
        }
    }
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {
            if let scheduleData = applicationContext["schedule"] as? Data,
               let schedule = try? JSONDecoder().decode(GroupSched.self, from: scheduleData) {
                self.receivedSchedule = schedule
                print("Данные получены и сохранены")
            }
        }
    }
    private func saveSchedule(_ schedule: GroupSched) {
        if let encoded = try? JSONEncoder().encode(schedule) {
            UserDefaults.standard.set(encoded, forKey: "schedule")
            print("Schedule saved to UserDefaults")
        }
    }
    
    private func loadSchedule() {
        if let data = UserDefaults.standard.data(forKey: "schedule"),
           let decoded = try? JSONDecoder().decode(GroupSched.self, from: data) {
            self.receivedSchedule = decoded
            print("Schedule loaded from UserDefaults")
        }
    }
}


