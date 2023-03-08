import SwiftUI
import OrderedCollections
import UIComponent
import SQLite

final class Card: ObservableObject {
    var id: Int64
    var budgetID: Int64
    @Published var index: Int
    @Published var name: String
    @Published var amount: Decimal
    @Published var cost: Decimal
    @Published var balance: Decimal
    @Published var display: Card.Display
    @Published var color: Color
    @Published var fixed: Bool
    @Published var dateDict: OrderedDictionary<Int, RecordSet>
    
    init(
        id: Int64 = 0,
        budgetID: Int64 = 0,
        index: Int = 0,
        name: String,
        amount: Decimal,
        display: Card.Display = .month,
        records: [Record] = [],
        color: Color,
        fixed: Bool = false
    ) {
        self.id = id
        self.budgetID = budgetID
        self.index = index
        self.name = name
        self.amount = amount
        self.display = display
        self.color = color
        self.fixed = fixed || display == .forever
        
        self.cost = 0
        self.balance = 0
        self.dateDict = [:]
        for record in records {
            if dateDict[record.date.unixDay] == nil {
                dateDict[record.date.unixDay] = RecordSet()
            }
            dateDict[record.date.unixDay]?.records.append(record)
            dateDict[record.date.unixDay]?.cost += record.cost
            self.cost += record.cost
        }
        self.balance = self.amount - self.cost
    }
}

// MARK: Identifiable
extension Card: Identifiable {}

// MARK: Hashable
extension Card: Hashable {
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.id == rhs.id
    }
    
    var hashValue: Int {
        return id.hashValue
    }
    
    func hash(into hasher: inout Hasher) {}
}

// MARK: Property
extension Card {
    var tag: LocalizedStringKey {
        return display.cardTag
    }
}

// MARK: Method
extension Card {}

// MARK: Static Property
extension Card {
    static let empty = Card(id: -1, budgetID: -1, index: -1, name: "", amount: 0, color: .blue)
    var isZero: Bool { self.id == -1 }
}


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
        
        var isForever: Bool {
            self == .forever
        }
        
        static var avaliable: [Card.Display] {
            return [.month, .forever]
        }
    }
}

// MARK: - Card.RecordSet
extension Card {
    class RecordSet: ObservableObject {
        @Published var records: [Record] = []
        @Published var cost: Decimal = 0
    }
}
