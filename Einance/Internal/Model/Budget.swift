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
            if card.isForever { continue }
            self.amount += card.amount
            self.cost += card.cost
        }
        
        self.balance = self.amount - self.cost
    }
}

// MARK: Identifiable
extension Budget: Identifiable {}

// MARK: Static Property
extension Budget {
    static let empty = Budget(id: -1, start: .zero, book: [.empty])
    var isZero: Bool { self.id == -1 }
}

// MARK: Hashable
extension Budget: Hashable {
    static func == (lhs: Budget, rhs: Budget) -> Bool {
        return lhs.id == rhs.id
    }
    
    var hashValue: Int {
        return id.hashValue
    }
    
    func hash(into hasher: inout Hasher) {}
}

//MARK: Method
extension Budget {
    func Update(_ newValue: Budget) {
        self.id = newValue.id
        self.start = newValue.start
        self.amount = newValue.amount
        self.cost = newValue.cost
        self.balance = newValue.balance
        self.book = newValue.book
    }
    
    func NextStartDate(_ baseNumber: Int) -> Date {
        return start.AddMonth(1).firstDayOfMonth.AddDay(baseNumber-1)
    }
    
    func IsExpired(_ baseNumber: Int) -> Bool {
        return Date.now >= NextStartDate(baseNumber)
    }
}
