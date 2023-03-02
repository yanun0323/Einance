import SwiftUI
import OrderedCollections
import UIComponent
import SQLite

final class Card {
    var id: Int64
    var budgetID: Int64
    var index: Int
    var name: String
    var amount: Decimal
    var cost: Decimal
    var balance: Decimal
    var display: Card.Display
    var color: Color
    var fixed: Bool
    var dateDict: OrderedDictionary<Date,RecordSet>
    
    init(
        id: Int64 = 0,
        budgetID: Int64 = 0,
        index: Int = 0,
        name: String,
        amount: Decimal,
        cost: Decimal = 0,
        balance: Decimal = 0,
        display: Card.Display = .month,
        records: [Record] = [],
        color: Color,
        fixed: Bool = true
    ) {
        self.id = id
        self.budgetID = budgetID
        self.index = index
        self.name = name
        self.amount = amount
        self.display = display
        self.color = color
        self.fixed = fixed
        
        self.cost = cost
        self.balance = balance
        self.dateDict = [:]
        for record in records {
            if dateDict[record.date] == nil {
                dateDict[record.date] = RecordSet(records: [], cost: 0)
            }
            dateDict[record.date]?.records.append(record)
            dateDict[record.date]?.cost += record.cost
            self.cost += record.cost
        }
        self.balance = self.amount - self.cost
    }
}

extension Card: Identifiable {}

extension Card: Hashable {
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.id == rhs.id
    }
    
    var hashValue: Int {
        return id.hashValue
    }
    
    func hash(into hasher: inout Hasher) {}
}

// MARK: - Property
extension Card {
    var tag: LocalizedStringKey {
        return display.cardTag
    }
}

// MARK: - Function
extension Card {}

// MARK: - Card.Display
extension Card {
    enum Display: Int, CaseIterable, Identifiable {
        case day, week, month, forever
        var id: Self { self }
        
        init(_ int: Int16) {
            self = Display(rawValue: Int(int)) ?? .forever
        }
        
        init(_ int64: Int64) {
            self = Display(rawValue: Int(int64)) ?? .forever
        }
        
        var string: LocalizedStringKey {
            switch self {
            case .day:
                return "card.display.day"
            case .week:
                return "card.display.week"
            case .month:
                return "card.display.month"
            case .forever:
                return "card.display.forever"
            }
        }
        
        var cardTag: LocalizedStringKey {
            switch self {
            case .day:
                return "card.display.day.cardTag"
            case .week:
                return "card.display.week.cardTag"
            case .month:
                return "card.display.month.cardTag"
            case .forever:
                return "card.display.forever.cardTag"
            }
        }
    }
}

// MARK: - Card.RecordSet
extension Card {
    struct RecordSet {
        var records: [Record]
        var cost: Decimal
    }
}

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
