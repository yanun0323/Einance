import SwiftUI
import OrderedCollections

final class Card {
    var uuid: UUID
    var index: Int
    var name: String
    var amount: Decimal
    var display: Card.Display
    var records: [Record]
    var color: Color
    var fixed: Bool
    
    /* Cache */
    var cost: Decimal
    var balance: Decimal
    var dateDict: OrderedDictionary<Date,RecordSet>
    
    init(uuid: UUID = .init(), index: Int = 0, name: String, amount: Decimal, display: Card.Display = .month, records: [Record] = [], color: Color, fixed: Bool = true) {
        self.uuid = uuid
        self.index = index
        self.name = name
        self.amount = amount
        self.display = display
        self.records = records
        self.color = color
        self.fixed = fixed
        
        self.cost = 0
        self.balance = 0
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
    
    init(_ mo: CardMO) {
        self.uuid = mo.uuid
        self.index = Int(mo.index)
        self.name = mo.name
        self.amount = mo.amount as Decimal
        self.display = Card.Display(rawValue: mo.display)
    }
}

extension Card: Identifiable {}
extension Card: Hashable {
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    var hashValue: Int {
        return uuid.hashValue
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
