import SwiftUI
import SQLite

// MARK: - Budget
extension Budget {
    static func Table() -> SQLite.Table { .init("budgets") }
    
    static let id = Expression<Int64>("id")
    static let startAt = Expression<Date>("start_at")
    static let archiveAt = Expression<Date?> ("archive_at")
    static let amount = Expression<Decimal>("amount")
    static let cost = Expression<Decimal>("cost")
    static let balance = Expression<Decimal>("balance")
    
    static func migrate(_ conn: Connection) throws {
        try conn.run(Table().create { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(startAt) //, unique: true)
            t.column(archiveAt)
            t.column(amount)
            t.column(cost)
            t.column(balance)
        })
    }
}

// MARK: - Card
extension Card {
    static func Table() -> SQLite.Table { .init("cards") }
    
    static let id = Expression<Int64>("id")
    static let chainID = Expression<UUID>("chain_id")
    static let budgetID = Expression<Int64>("budget_id")
    static let index = Expression<Int>("index")
    static let name = Expression<String>("name")
    static let amount = Expression<Decimal>("amount")
    static let cost = Expression<Decimal>("cost")
    static let balance = Expression<Decimal>("balance")
    static let display = Expression<Card.Display>("display")
    static let fixed = Expression<Bool>("fixed")
    static let fontColor = Expression<Color>("font_color")
    static let color = Expression<Color>("color")
    
    static func migrate(_ conn: Connection) throws {
        try conn.run(Table().addColumn(fontColor, defaultValue: .white))
        try conn.run(Table().create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(chainID)
            t.column(budgetID)
            t.column(index)
            t.column(name)
            t.column(amount)
            t.column(cost)
            t.column(balance)
            t.column(display)
            t.column(fixed)
            t.column(fontColor)
            t.column(color)
        })
        try conn.run(Table().createIndex(chainID, ifNotExists: true))
        try conn.run(Table().createIndex(budgetID, ifNotExists: true))
    }
}

// MARK: - Record
extension Record {
    static func Table() -> SQLite.Table { .init("records") }
    
    static let id = Expression<Int64>("id")
    static let cardID = Expression<Int64>("card_id")
    static let date = Expression<Date>("date")
    static let cost = Expression<Decimal>("cost")
    static let memo = Expression<String>("memo")
    static let fixed = Expression<Bool>("fixed")
    
    static func migrate(_ conn: Connection) throws {
        try conn.run(Table().create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(cardID)
            t.column(date)
            t.column(cost)
            t.column(memo)
            t.column(fixed)
        })
        try conn.run(Table().createIndex(cardID, ifNotExists: true))
        try conn.run(Table().createIndex(date, ifNotExists: true))
    }
}

// MARK: - Tag
extension Tag {
    static func Table() -> SQLite.Table { .init("tags") }
    
    static let id = Expression<Int64>("id")
    static let chainID = Expression<UUID>("chain_id")
    static let value = Expression<String>("value")
    static let count = Expression<Int>("count")
    static let type = Expression<TagType>("type")
    static let updatedAti = Expression<Int>("updated_ati")
    
    static func migrate(_ conn: Connection) throws {
        try conn.run(Table().create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(chainID)
            t.column(value)
            t.column(type)
            t.column(count)
            t.column(updatedAti)
        })
        try conn.run(Table().createIndex(chainID, ifNotExists: true))
        try conn.run(Table().createIndex(value, ifNotExists: true))
        try conn.run(Table().createIndex(type, ifNotExists: true))
        try conn.run(Table().createIndex(updatedAti, ifNotExists: true))
    }
}
