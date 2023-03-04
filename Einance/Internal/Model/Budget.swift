import SwiftUI
import SQLite

final class Budget: ObservableObject {
    var id: Int64
    @Published var start: Date
    @Published var amount: Decimal
    @Published var cost: Decimal
    @Published var balance: Decimal
    @Published var book: [Card]
    
    init(
        id: Int64 = 0,
        start: Date,
        book: [Card] = []
    ) {
        self.id = id
        self.start = start
        self.book = book
        self.amount = 0
        self.balance = 0
        self.cost = 0
        
        for card in book {
            self.amount += card.amount
            self.cost += card.cost
        }
        
        self.balance = self.amount - self.cost
    }
}

extension Budget: Identifiable {}

extension Budget {
    static let empty = Budget(id: -1, start: .zero, book: [.empty])
    var isZero: Bool { self.id == -1 }
}

