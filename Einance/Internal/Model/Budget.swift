import SQLite
import SwiftUI

final class Budget: ObservableObject {
    var id: Int64
    
    @Published var startAt: Date
    @Published var archiveAt: Date?
    @Published var amount: Decimal
    @Published var cost: Decimal
    @Published var balance: Decimal
    @Published var book: [Card]
    @Published var updatedAt: Int
    
    internal init(budget: Budget) {
        self.id = budget.id
        self.startAt = budget.startAt
        self.archiveAt = budget.archiveAt
        self.amount = budget.amount
        self.cost = budget.cost
        self.balance = budget.balance
        self.book = budget.book
        self.updatedAt = budget.updatedAt
    }

    init(
        id: Int64 = 0,
        startAt: Date,
        archiveAt: Date? = nil,
        book: [Card] = [],
        updatedAt: Int = Date.now.unix
    ) {
        self.id = id
        self.startAt = startAt
        self.book = book
        self.amount = 0
        self.balance = 0
        self.cost = 0
        self.archiveAt = archiveAt
        self.updatedAt = updatedAt

        for card in book {
            if card.isForever { continue }
            amount += card.amount
            cost += card.cost
        }

        balance = amount - cost
    }
}

// MARK: Identifiable
extension Budget: Identifiable {}

// MARK: Categoriable
extension Budget: Categoriable {}

// MARK: Static Property
extension Budget {
    static func blank() -> Budget { Budget(id: -1, startAt: .zero, book: [.blank()], updatedAt: 0) }
    var isBlank: Bool { self.id == -1 }
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
        self.updatedAt = newValue.updatedAt
    }

    func NextStartDate(_ baseNumber: Int) -> Date {
        return startAt.addMonth(1).firstDayOfMonth.addDay(baseNumber - 1)
    }

    func IsExpired(_ baseNumber: Int) -> Bool {
        return Date.now >= NextStartDate(baseNumber)
    }

    func HasCard() -> Bool {
        return self.book.count != 0
    }
}

extension Budget: Codable {
    enum CodingKeys: CodingKey {
        case id
        case startAt
        case archiveAt
        case amount
        case cost
        case balance
        case book
        case updatedAt
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.startAt, forKey: .startAt)
        try container.encodeIfPresent(self.archiveAt, forKey: .archiveAt)
        try container.encode(self.amount, forKey: .amount)
        try container.encode(self.cost, forKey: .cost)
        try container.encode(self.balance, forKey: .balance)
        try container.encode(self.book, forKey: .book)
        try container.encode(self.updatedAt, forKey: .updatedAt)
    }
    
    convenience init(from decoder: Decoder) throws {
        let b =  Budget(startAt: .now)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        b.id = try container.decode(Int64.self, forKey: .id)
        b.startAt = try container.decode(Date.self, forKey: .startAt)
        b.archiveAt = try container.decodeIfPresent(Date.self, forKey: .archiveAt)
        b.amount = try container.decode(Decimal.self, forKey: .amount)
        b.cost = try container.decode(Decimal.self, forKey: .cost)
        b.balance = try container.decode(Decimal.self, forKey: .balance)
        b.book = try container.decode([Card].self, forKey: .book)
        b.updatedAt = try container.decode(Int.self, forKey: .updatedAt)
        self.init(budget: b)
    }
}
