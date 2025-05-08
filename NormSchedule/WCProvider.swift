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
    private var pendingContext = [String: Any]()
    private var session: WCSession?
    private let queue = DispatchQueue(label: "com.KirillArkhipov.NormSchedule.wcprovider.context")

    private override init() {
        super.init()
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
            print("Session initialized")
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        queue.async {
            if let error = error {
                print("Activation error: \(error.localizedDescription)")
                return
            }

            print("Session activated: \(activationState.rawValue)")
            self.sendPendingContext()
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Session Inactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("Session Deactivated")
    }

    func update(schedule: GroupSched?, parity: Int) {
        queue.async {
            if let schedule = schedule {
                do {
                    let data = try JSONEncoder().encode(schedule)
                    self.pendingContext["schedule"] = data
                } catch {
                    print("Schedule encoding error: \(error)")
                }
            }
            self.pendingContext["parity"] = parity
            
            self.sendContextImmediately()
        }
    }

    private func sendContextImmediately() {
        guard let session = session else {
            print("WCSession not supported")
            return
        }

        guard session.activationState == .activated else {
            print("Session not active, saving to pending")
            return
        }

        do {
            print("Context successfully sent: \(pendingContext.keys)")
            try session.updateApplicationContext(pendingContext)
            pendingContext = [:]
        } catch {
            print("Context send error: \(error)")
        }
    }

    private func sendPendingContext() {
        guard !pendingContext.isEmpty else { return }
        sendContextImmediately()
    }

}
