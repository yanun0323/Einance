import SwiftUI
import SQLite

final class Budget {
    var id: Int64
    var start: Date
    var amount: Decimal
    var cost: Decimal
    var balance: Decimal
    var book: [Card]
    
    init(
        id: Int64 = 0,
        start: Date,
        amount: Decimal = 0,
        cost: Decimal = 0,
        balance: Decimal = 0,
        book: [Card] = []
    ) {
        self.id = id
        self.start = start
        self.book = book
        self.amount = amount
        self.balance = balance
        self.cost = cost
        
        for card in book {
            self.amount += card.amount
            self.cost += card.cost
        }
        self.balance = self.amount - self.cost
    }
}

extension Budget: Identifiable {}

extension Budget {
    static func GetTable() -> SQLite.Table { .init("budgets") }
    
    static let id = Expression<Int64>("id")
    static let start = Expression<Date>("start")
    static let amount = Expression<Decimal>("amount")
    static let cost = Expression<Decimal>("cost")
    static let balance = Expression<Decimal>("balance")
    
    static func migrate(_ conn: Connection) throws {
        try conn.run(GetTable().create { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(start, unique: true)
            t.column(amount)
            t.column(cost)
            t.column(balance)
        })
    }
}
