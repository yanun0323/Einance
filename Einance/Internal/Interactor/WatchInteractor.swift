import SwiftUI
import Ditto
import WatchConnectivity
import Combine

class WatchInteractor: NSObject {
    private var appstate: AppState
    private var repo: Repository
    private var setting: UserSettingInteractor
    private var session: WCSession
    private var subscribeBudget: Cancellable?
    
    init(appstate: AppState, repo: Repository, setting: UserSettingInteractor) {
        self.appstate = appstate
        self.repo = repo
        self.session = .default
        self.setting = setting
        self.subscribeBudget = nil
        
        super.init()
        
        if WCSession.isSupported() {
            session.delegate = self
        }
        session.activate()
    }
}

extension WatchInteractor {
    func setupSubscribe() {
        subscribeBudget?.cancel()
        subscribeBudget = appstate.budgetPublisher.sink { value in
            guard let b = value else { return }
            print("send current budget to watchOS")
            self.sendCurrentBudget(b)
        }
    }
}

// MARK: Receive
extension WatchInteractor: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        let err = error == nil ? "-" : "\(error!)"
        print("activationDidCompleteWith: \(activationState), err: \(err)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("sessionDidBecomeInactive")
        session.activate()
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("sessionDidDeactivate")
        // If the person has more than one watch, and they switch,
        // reactivate their session on the new 
        session.activate()
    }
    
    // Message Immediately
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
    }
    
    // ApplicationContext Newest
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("receive application context")
    }
    
    // UserInfo FIFO
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        if let record = userInfo[ConnectivityKey.createRecordRequest.rawValue] as? Record {
            handleCreateRecord(record: record)
        }
        
        if let message = userInfo[ConnectivityKey.message.rawValue] as? String {
            print("[watchOS] \(message)")
            sendMessage()
        }
    }
    
    private func handleCreateRecord(record: Record) -> Void {
        _ = System.doCatch("handle create record") {
            _ = try repo.CreateRecord(record)
            guard let budget = try repo.GetLastBudget() else { return }
            System.async {
                self.appstate.budgetPublisher.send(budget)
            }
        }
    }
}

// MARK: Send
extension WatchInteractor {
    func sendCurrentBudget(_ b: Budget) -> Void {
        guard let data = System.doCatch("encode budget", {
            return try JSONEncoder().encode(b)
        }) else { return }
        let key = ConnectivityKey.currentBudgetReply.rawValue
        guard let _ = session.applicationContext[key] else {
            send(session, .highPriority, [key: data])
            return
        }
        System.doCatch("update application context") {
            try session.updateApplicationContext([key: data])
        }
    }
    
    func sendMessage(_ message: String? = nil) {
        let msg = message ?? Date.now.string("yyyy-MM-dd hh:mm:ss")
        print("send message (\(msg) to watch")
        send(session, .guaranteed, [
            ConnectivityKey.message.rawValue: msg
        ])
    }
}
