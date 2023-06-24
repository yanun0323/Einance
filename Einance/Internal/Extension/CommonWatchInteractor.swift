import SwiftUI
import Ditto
import WatchConnectivity

extension WatchInteractor {
    internal func send(_ session: WCSession, _ delivery: Delivery, _ dataDict: [String: Any], replyHandler: (([String : Any]) -> Void)? = nil) {
        switch delivery {
            case .failable:
                session.sendMessage(dataDict, replyHandler: replyHandler)
            case .guaranteed:
                session.transferUserInfo(dataDict)
            case .highPriority:
                System.doCatch("invoke application context") {
                    try session.updateApplicationContext(dataDict)
                }
        }
    }
}
