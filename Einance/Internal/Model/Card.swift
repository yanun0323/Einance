import SwiftUI
import OrderedCollections
import UIComponent
import SQLite

final class Card: ObservableObject {
    var id: Int64
    var chainID: UUID
    var budgetID: Int64
    @Published var index: Int
    @Published var name: String
    @Published var amount: Decimal
    @Published var cost: Decimal
    @Published var balance: Decimal
    @Published var display: Card.Display
    @Published var color: Color
    @Published var fixed: Bool
    @Published var dateDict: OrderedDictionary<Date, RecordSet>
    @Published var pinnedArray: [Record] = []
    @Published var pinnedCost: Decimal = 0
    
    init(
        id: Int64 = 0,
        chainID: UUID = UUID(),
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
        self.chainID = chainID
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
        for r in records {
            if r.fixed {
                AddRecordToFixed(r)
            } else {
                AddRecordToDict(r)
            }
            self.cost += r.cost
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
    var isForever: Bool { self.display == .forever }
    
    var hasFixRecord: Bool { !self.pinnedArray.isEmpty }
    
    var hasDateRecord: Bool { !self.dateDict.isEmpty }
    
    var hasRecord: Bool { hasFixRecord || hasDateRecord }
}

// MARK: Method
extension Card {
    
    // MARK: Public
    
    func RemoveRecordFromDict(_ r: Record) {
        let key = r.date.key
        if dateDict[key].isNil { return }
        dateDict[key]!.records.removeAll(where: { $0.id == r.id })
        dateDict[key]!.cost -= r.cost
        cleanDictIfExist(key)
    }
    
    func AddRecordToDict(_ r: Record) {
        let key = r.date.key
        createDictIfNotExist(key)
        dateDict[key]!.records.append(r)
        dateDict[key]!.cost += r.cost
    }
    
    func AddRecordToFixed(_ r: Record) {
        pinnedArray.append(r)
        pinnedCost += r.cost
    }
    
    func RemoveRecordFromFixed(_ r: Record) {
        pinnedArray.removeAll(where: { $0.id == r.id })
        pinnedCost -= r.cost
    }
    
    func MoveRecordDictToFixed(_ r: Record) {
        RemoveRecordFromDict(r)
        AddRecordToFixed(r)
    }
    
    func MoveRecordFixedToDict(_ r: Record) {
        RemoveRecordFromFixed(r)
        AddRecordToDict(r)
    }
    
    // MARK: Private
    
    private func cleanDictIfExist(_ key: Date) {
        if dateDict[key].isNil || dateDict[key]!.records.count != 0 { return }
        dateDict.removeValue(forKey: key)
    }
    
    private func createDictIfNotExist(_ key: Date) {
        if dateDict[key].isNil {
            dateDict[key] = RecordSet()
        }
        dateDict.sort()
    }
}

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
