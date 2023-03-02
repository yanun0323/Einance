import SwiftUI
import SQLite

class Record {
    var id: Int64
    var cardID: Int64
    var date: Date
    var cost: Decimal
    var memo: String
    
    init(
        id: Int64 = 0,
        cardID: Int64 = 0,
        date: Date = .now,
        cost: Decimal = 0,
        memo: String = ""
    ) {
        self.id = id
        self.cardID = cardID
        self.date = date
        self.cost = cost
        self.memo = memo
    }
}

extension Record: Identifiable {}

extension Record {
    static func GetTable() -> SQLite.Table { .init("records") }
    
    static let id = Expression<Int64>("id")
    static let cardID = Expression<Int64>("card_id")
    static let date = Expression<Date>("date")
    static let cost = Expression<Decimal>("cost")
    static let memo = Expression<String>("memo")
    
    static func migrate(_ conn: Connection) throws {
        try conn.run(GetTable().create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(cardID)
            t.column(date)
            t.column(cost)
            t.column(memo)
        })
    }
}
