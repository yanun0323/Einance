import SwiftUI
import SQLite

final class Budget: ObservableObject {
    var id: Int64
    @Published var startAt: Date
    @Published var archiveAt: Date?
    @Published var amount: Decimal
    @Published var cost: Decimal
    @Published var balance: Decimal
    @Published var book: [Card]
    
    init(
        id: Int64 = 0,
        startAt: Date,
        archiveAt: Date? = nil,
        book: [Card] = []
    ) {
        self.id = id
        self.startAt = startAt
        self.book = book
        self.amount = 0
        self.balance = 0
        self.cost = 0
        self.archiveAt = archiveAt
        
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
    static let empty = Budget(id: -1, startAt: .zero, book: [.empty])
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
        self.startAt = newValue.startAt
        self.archiveAt = newValue.archiveAt
        self.amount = newValue.amount
        self.cost = newValue.cost
        self.balance = newValue.balance
        self.book = newValue.book
    }
    
    func NextStartDate(_ baseNumber: Int) -> Date {
        return startAt.AddMonth(1).firstDayOfMonth.AddDay(baseNumber-1)
    }
    
    func IsExpired(_ baseNumber: Int) -> Bool {
        return Date.now >= NextStartDate(baseNumber)
    }
    
    func HasCard() -> Bool {
        return self.book.count != 0
    }
}
