import SwiftUI
import SQLite

// MARK: - Budget
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
            t.column(start) //, unique: true)
            t.column(amount)
            t.column(cost)
            t.column(balance)
        })
    }
}

// MARK: - Card
extension Card {
    static func GetTable() -> SQLite.Table { .init("cards") }
    
    static let id = Expression<Int64>("id")
    static let budgetID = Expression<Int64>("budget_id")
    static let index = Expression<Int>("index")
    static let name = Expression<String>("name")
    static let amount = Expression<Decimal>("amount")
    static let cost = Expression<Decimal>("cost")
    static let balance = Expression<Decimal>("balance")
    static let display = Expression<Card.Display>("display")
    static let fixed = Expression<Bool>("fixed")
    static let color = Expression<Color>("color")
    
    static func migrate(_ conn: Connection) throws {
        try conn.run(GetTable().create { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(budgetID)
            t.column(index)
            t.column(name)
            t.column(amount)
            t.column(cost)
            t.column(balance)
            t.column(display)
            t.column(fixed)
            t.column(color)
        })
    }
}

// MARK: - Record
extension Record {
    static func GetTable() -> SQLite.Table { .init("records") }
    
    static let id = Expression<Int64>("id")
    static let cardID = Expression<Int64>("card_id")
    static let date = Expression<Date>("date")
    static let cost = Expression<Decimal>("cost")
    static let memo = Expression<String>("memo")
    static let fixed = Expression<Bool>("fixed")
    
    static func migrate(_ conn: Connection) throws {
        try conn.run(GetTable().create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(cardID)
            t.column(date)
            t.column(cost)
            t.column(memo)
            t.column(fixed)
        })
    }
}
