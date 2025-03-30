//
//  WCProvider.swift
//  NormSchedule
//
//  Created by Кирилл Архипов on 03.03.2025.
//

import Foundation
import WatchConnectivity

class WCProvider: NSObject, WCSessionDelegate, ObservableObject {

    static let shared = WCProvider()
    private var pendingSchedule: GroupSched?

    private var session: WCSession?

    private override init() {
        super.init()
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
            print("Сессия активирована")
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Session activation failed with error: \(error.localizedDescription)")
        } else {
            print("Session activated with state: \(activationState.rawValue)")
            sendPendingSchedule()
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Session Inactive")
        session.activate()
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("Session Deactivated")
        session.activate()
    }

    public func updateSchedule(schedule: GroupSched) {
        guard let session = session else {
            print("WCSession is not supported.")
            return
        }

        if session.activationState == .activated {
            do {
                let data = try JSONEncoder().encode(schedule)
                try session.updateApplicationContext(["schedule": data])
            } catch {
                print("Updating of application context failed: \(error)")
            }
        } else {
            pendingSchedule = schedule
            print("Session is not activated yet. Context saved to buffer.")
        }
    }

    private func sendPendingSchedule() {
        guard let session = session, session.activationState == .activated else {
            return
        }
        if let schedule = pendingSchedule {
            updateSchedule(schedule: schedule)
        }
        pendingSchedule = nil
    }

}
