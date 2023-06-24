import SwiftUI

enum ConnectivityKey: String {
    /* iOS -> watch */
    case currentBudgetReply = "CurrentBudgetReply"
    
    /* watch -> iOS */
    case createRecordRequest = "CreateRecordRequest"
    
    case message = "Message"
}
