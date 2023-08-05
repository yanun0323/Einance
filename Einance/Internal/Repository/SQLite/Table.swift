import SwiftUI
import SQLite
import Sworm

extension SQL {
    static func listSchema(_ tableName: String) throws {
        let columns = try getDriver().schema.columnDefinitions(table: tableName)
        print("")
        print("'\(tableName)' schema:")
        for column in columns {
            print("'\(column.name)',pk:\(!column.primaryKey.isNil),null: \(column.nullable)")
        }
    }
}

// MARK: - Budget
extension Budget: Migrator {
    static var table: Tablex { .init("budgets") }
    
    static let id = Expression<Int64>("id")
    static let startAt = Expression<Date>("start_at")
    static let archiveAt = Expression<Date?> ("archive_at")
    static let amount = Expression<Decimal>("amount")
    static let cost = Expression<Decimal>("cost")
    static let balance = Expression<Decimal>("balance")
    static let updatedAt = Expression<Int>("updated_at")
    
    static func migrate(_ conn: Connection) throws {
        #if DEBUG
        try SQL.listSchema("budgets")
        #endif
        try conn.run(table.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(startAt, unique: true)
            t.column(archiveAt)
            t.column(amount)
            t.column(cost)
            t.column(balance)
            t.column(updatedAt)
        })
        try conn.run(table.createIndex(startAt, ifNotExists: true))
    }
    
    static func parse(_ row: Row) throws -> Budget {
        return Budget(
            id: try row.get(id),
            startAt: try row.get(startAt),
            archiveAt: try row.get(archiveAt)
        )
    }
    
    func setter() -> [Setter] {
        return [
            Budget.startAt <- startAt,
            Budget.archiveAt <- archiveAt,
            Budget.amount <- amount,
            Budget.cost <- cost,
            Budget.balance <- balance,
            Budget.updatedAt <- updatedAt
        ]
    }
}

// MARK: - Card
extension Card: Migrator {
    static var table: Tablex { .init("cards") }
    
    static let id = Expression<Int64>("id")
    static let chainID = Expression<UUID>("chain_id")
    static let budgetID = Expression<Int64>("budget_id")
    static let index = Expression<Int>("index")
    static let name = Expression<String>("name")
    static let amount = Expression<Decimal>("amount")
    static let cost = Expression<Decimal>("cost")
    static let balance = Expression<Decimal>("balance")
    static let display = Expression<Card.Display>("display")
    static let pinned = Expression<Bool>("pinned")
    static let fColor = Expression<Color>("foreground_color")
    static let bColor = Expression<Color>("background_color")
    static let gColor = Expression<Color?>("gradient_color")
    static let updatedAt = Expression<Int>("updated_at")
    
    static func migrate(_ conn: Connection) throws {
        #if DEBUG
        try SQL.listSchema("cards")
        #endif
        try conn.run(table.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(chainID)
            t.column(budgetID)
            t.column(index)
            t.column(name)
            t.column(amount)
            t.column(cost)
            t.column(balance)
            t.column(display)
            t.column(pinned)
            t.column(updatedAt)
            t.column(fColor)
            t.column(bColor)
            t.column(gColor)
        })
        try conn.run(table.createIndex(chainID, ifNotExists: true))
        try conn.run(table.createIndex(budgetID, ifNotExists: true))
    }
    
    static func parse(_ row: Row) throws -> Card {
        return Card(
            id: try row.get(id),
            chainID: try row.get(chainID),
            budgetID: try row.get(budgetID),
            index: try row.get(index),
            name: try row.get(name),
            amount: try row.get(amount),
            display: try row.get(display),
            fColor: try row.get(fColor),
            bColor: try row.get(bColor),
            gColor: try row.get(gColor),
            pinned: try row.get(pinned)
        )
    }
    
    func setter() -> [Setter] {
        return [
            Card.chainID <- chainID,
            Card.budgetID <- budgetID,
            Card.index <- index,
            Card.name <- name,
            Card.amount <- amount,
            Card.cost <- cost,
            Card.balance <- balance,
            Card.display <- display,
            Card.fColor <- fColor,
            Card.bColor <- bColor,
            Card.gColor <- gColor,
            Card.pinned <- pinned,
            Card.updatedAt <- Date.now.unix
        ]
    }
}

// MARK: - Record
extension Record: Migrator {
    static var table: Tablex { .init("records") }
    
    static let id = Expression<Int64>("id")
    static let cardID = Expression<Int64>("card_id")
    static let date = Expression<Date>("date")
    static let cost = Expression<Decimal>("cost")
    static let memo = Expression<String>("memo")
    static let pinned = Expression<Bool>("pinned")
    static let updatedAt = Expression<Int>("udpated_at")
    
    static func migrate(_ conn: Connection) throws {
        #if DEBUG
        try SQL.listSchema("records")
        #endif
        try conn.run(table.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(cardID)
            t.column(date)
            t.column(cost)
            t.column(memo)
            t.column(pinned)
            t.column(updatedAt)
        })
        try conn.run(table.createIndex(cardID, ifNotExists: true))
        try conn.run(table.createIndex(date, ifNotExists: true))
        try conn.run(table.createIndex(pinned, ifNotExists: true))
        try conn.run(table.createIndex(updatedAt, ifNotExists: true))
    }
    
    static func parse(_ row: Row) throws -> Record {
        return Record(
            id: try row.get(id),
            cardID: try row.get(cardID),
            date: try row.get(date),
            cost: try row.get(cost),
            memo: try row.get(memo),
            pinned: try row.get(pinned)
        )
    }
    
    func setter() -> [Setter] {
        return [
            Record.cardID <- cardID,
            Record.date <- date,
            Record.cost <- cost,
            Record.memo <- memo,
            Record.pinned <- pinned,
            Record.updatedAt <- Date.now.unix
        ]
    }
}

// MARK: - Tag
extension Tag: Migrator {
    static var table: Tablex { .init("tags") }
    
    static let id = Expression<Int64>("id")
    static let chainID = Expression<UUID>("chain_id")
    static let value = Expression<String>("value")
    static let count = Expression<Int>("count")
    static let type = Expression<TagType>("type")
    static let key = Expression<Int>("key")
    static let updatedAt = Expression<Int>("updated_at")
    
    static func migrate(_ conn: Connection) throws {
        #if DEBUG
        try SQL.listSchema("tags")
        #endif
        try conn.run(table.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(chainID)
            t.column(value)
            t.column(type)
            t.column(count)
            t.column(key)
            t.column(updatedAt)
        })
        try conn.run(table.createIndex(chainID, ifNotExists: true))
        try conn.run(table.createIndex(value, ifNotExists: true))
        try conn.run(table.createIndex(type, ifNotExists: true))
        try conn.run(table.createIndex(count, ifNotExists: true))
        try conn.run(table.createIndex(key, ifNotExists: true))
        try conn.run(table.createIndex(updatedAt, ifNotExists: true))
    }
    
    static func parse(_ row: Row) throws -> Tag {
        return Tag(
            id: try row.get(id),
            chainID: try row.get(chainID),
            type: try row.get(type),
            value: try row.get(value),
            count: try row.get(count),
            key: try row.get(key)
        )
    }
    
    func setter() -> [Setter] {
        return [
            Tag.chainID <- chainID,
            Tag.type <- type,
            Tag.value <- value,
            Tag.count <- count,
            Tag.key <- key,
            Tag.updatedAt <- Date.now.unix
        ]
    }
}
