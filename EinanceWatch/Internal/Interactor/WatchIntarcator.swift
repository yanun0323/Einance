import SwiftUI
import Ditto
import WatchConnectivity


class WatchInteractor: NSObject {
    private var appstate: AppState
    private var repo: WatchRepository
    private var session: WCSession
    
    init(appstate: AppState, repo: WatchRepository) {
        self.appstate = appstate
        self.repo = repo
        self.session = .default
        super.init()
        session.delegate = self
        session.activate()
    }
}

extension WatchInteractor {
    func getLastReceivedBudget() -> Budget? {
        return parseRecieveBudget(session.receivedApplicationContext)
    }
    
    func getStoredBudget() -> Budget? {
        return System.doCatch("get stored budget") {
            guard let data = try repo.getBudgetData() else { return nil }
            return try JSONDecoder().decode(Budget.self, from: data)
        }
    }
}

// MARK: Receive
extension WatchInteractor: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        let err = error == nil ? "-" : "\(error!)"
        print("activationDidCompleteWith: \(activationState), err: \(err)")
    }
    
    // ApplicationContext 背景，只收到最新的一筆資料
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("receive application context")
        handleReceiveBudget(applicationContext)
    }
    
    // UserInfo 背景，會依照 FIFO 依序收到資料
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        print("receive user info")
        handleReceiveMessage(userInfo)
    }
    

}

// MARK: Send
extension WatchInteractor {
    func sendMessage(_ message: String) {
        guard session.isCompanionAppInstalled else { return }
        send(session, .guaranteed, [
            ConnectivityKey.message.rawValue: message
        ])
    }
}


fileprivate extension WatchInteractor {
    private func handleReceiveBudget(_ context: [String : Any]) {
        if let data = context[ConnectivityKey.currentBudgetReply.rawValue] as? Data {
            guard let budget = System.doCatch("decode budget data", {
                return try JSONDecoder().decode(Budget.self, from: data)
            }) else { return }
            
            print("received budget from iOS: \(budget.updatedAt)")
            System.doCatch("upsert budget data") {
                try repo.upsertBudgetData(data)
            }
            System.async {
                self.appstate.currentBudget.send(budget)
            }
        }
    }
    
    private func parseRecieveBudget(_ context: [String : Any]) -> Budget? {
        guard let data = context[ConnectivityKey.currentBudgetReply.rawValue] as? Data
        else { return nil }
        
        guard let budget = System.doCatch("decode budget data", {
            return try JSONDecoder().decode(Budget.self, from: data)
        }) else { return nil }
        
        return budget
    }
    
    private func handleReceiveMessage(_ context: [String : Any]) {
        if let message = context[ConnectivityKey.message.rawValue] as? String {
            print("[iOS] \(message)")
            System.async {
                self.appstate.message.send(message)
            }
        }
    }
}
