import SwiftUI
import SQLite

class Record: ObservableObject {
    var id: Int64
    var cardID: Int64
    @Published var date: Date
    @Published var cost: Decimal
    @Published var memo: String
    @Published var fixed: Bool
    
    init(
        id: Int64 = 0,
        cardID: Int64 = 0,
        date: Date = .now,
        cost: Decimal = 0,
        memo: String = "",
        fixed: Bool = false
    ) {
        self.id = id
        self.cardID = cardID
        self.date = date
        self.cost = cost
        self.memo = memo
        self.fixed = fixed
    }
}

extension Record: Identifiable {}
