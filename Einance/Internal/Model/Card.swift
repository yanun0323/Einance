import Ditto
import OrderedCollections
import SQLite
import SwiftUI

final class Card: ObservableObject {
    typealias DateDict = OrderedDictionary<Date, RecordSet>

    var id: Int64
    var chainID: UUID
    var budgetID: Int64
    
    @Published var index: Int
    @Published var name: String
    @Published var amount: Decimal
    @Published var cost: Decimal
    @Published var balance: Decimal
    @Published var display: Card.Display
    
    @Published var fColor: Color
    @Published var bColor: Color
    @Published var gColor: Color?
    
    @Published var pinned: Bool
    @Published var dateDict: DateDict
    @Published var pinnedArray: [Record]
    @Published var pinnedCost: Decimal
    
    internal init(card: Card) {
        self.id = card.id
        self.chainID = card.chainID
        self.budgetID = card.budgetID
        self.index = card.index
        self.name = card.name
        self.amount = card.amount
        self.cost = card.cost
        self.balance = card.balance
        self.display = card.display
        self.fColor = card.fColor
        self.bColor = card.bColor
        self.gColor = card.gColor
        self.pinned = card.pinned
        self.dateDict = card.dateDict
        self.pinnedArray = card.pinnedArray
        self.pinnedCost = card.pinnedCost
    }
    
    init(
        id: Int64 = 0,
        chainID: UUID = UUID(),
        budgetID: Int64 = 0,
        index: Int = 0,
        name: String,
        amount: Decimal,
        display: Card.Display = .month,
        records: [Record] = [],
        fColor: Color = .white,
        bColor: Color = .cyan,
        gColor: Color? = nil,
        pinned: Bool = false
    ) {
        self.id = id
        self.chainID = chainID
        self.budgetID = budgetID
        self.index = index
        self.name = name
        self.amount = amount
        self.display = display
        self.pinned = pinned || display == .forever
        self.fColor = fColor
        self.bColor = bColor
        self.gColor = gColor
        self.cost = 0
        self.balance = 0
        
        self.dateDict = DateDict()
        self.pinnedArray = []
        self.pinnedCost = 0
        
        for r in records {
            if r.pinned {
                AddRecordToFixed(r)
            } else {
                AddRecordToDict(r)
            }
            cost += r.cost
        }
        balance = amount - cost
    }
}

// MARK: Identifiable
extension Card: Identifiable {}

// MARK: Categoriable
extension Card: Categoriable {}

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

    var bgColor: [Color] { [bColor, gColor ?? bColor] }
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
    static func blank() -> Card { Card(id: -1, budgetID: -1, index: -1, name: "", amount: 0) }
    var isBlank: Bool { self.id == -1 }
}

// MARK: - Card.Display
extension Card {
    enum Display: Int, CaseIterable, Identifiable, Codable {
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
    final class RecordSet: ObservableObject {
        
        @Published var records: [Record] = []
        @Published var cost: Decimal = 0
        
        init(records: [Record] = [], cost: Decimal = 0) {
            self.records = records
            self.cost = cost
        }
    }
}

extension Card: Codable {
    enum CodingKeys: CodingKey {
        case id
        case chainID
        case budgetID
        case index
        case name
        case amount
        case cost
        case balance
        case display
        case fColor
        case bColor
        case gColor
        case pinned
        case dateDict
        case pinnedArray
        case pinnedCost
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.chainID, forKey: .chainID)
        try container.encode(self.budgetID, forKey: .budgetID)
        try container.encode(self.index, forKey: .index)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.amount, forKey: .amount)
        try container.encode(self.cost, forKey: .cost)
        try container.encode(self.balance, forKey: .balance)
        try container.encode(self.display, forKey: .display)
        try container.encode(self.fColor, forKey: .fColor)
        try container.encode(self.bColor, forKey: .bColor)
        try container.encodeIfPresent(self.gColor, forKey: .gColor)
        try container.encode(self.pinned, forKey: .pinned)
        try container.encode(self.dateDict, forKey: .dateDict)
        try container.encode(self.pinnedArray, forKey: .pinnedArray)
        try container.encode(self.pinnedCost, forKey: .pinnedCost)
    }
    
    convenience init(from decoder: Decoder) throws {
        let c = Card(name: "", amount: 0)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        c.id = try container.decode(Int64.self, forKey: .id)
        c.chainID = try container.decode(UUID.self, forKey: .chainID)
        c.budgetID = try container.decode(Int64.self, forKey: .budgetID)
        c.index = try container.decode(Int.self, forKey: .index)
        c.name = try container.decode(String.self, forKey: .name)
        c.amount = try container.decode(Decimal.self, forKey: .amount)
        c.cost = try container.decode(Decimal.self, forKey: .cost)
        c.balance = try container.decode(Decimal.self, forKey: .balance)
        c.display = try container.decode(Card.Display.self, forKey: .display)
        c.fColor = try container.decode(Color.self, forKey: .fColor)
        c.bColor = try container.decode(Color.self, forKey: .bColor)
        c.gColor = try container.decodeIfPresent(Color.self, forKey: .gColor)
        c.pinned = try container.decode(Bool.self, forKey: .pinned)
        c.dateDict = try container.decode(Card.DateDict.self, forKey: .dateDict)
        c.pinnedArray = try container.decode([Record].self, forKey: .pinnedArray)
        c.pinnedCost = try container.decode(Decimal.self, forKey: .pinnedCost)
        self.init(card: c)
    }
}

extension Card.RecordSet: Codable {
    enum CodingKeys: CodingKey {
        case records
        case cost
    }
    
    convenience init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<Card.RecordSet.CodingKeys> = try decoder.container(keyedBy: Card.RecordSet.CodingKeys.self)
        let records = try container.decode([Record].self, forKey: Card.RecordSet.CodingKeys.records)
        let cost = try container.decode(Decimal.self, forKey: Card.RecordSet.CodingKeys.cost)
        self.init(records: records, cost: cost)
    }
    
    func encode(to encoder: Encoder) throws {
        var container: KeyedEncodingContainer<Card.RecordSet.CodingKeys> = encoder.container(keyedBy: Card.RecordSet.CodingKeys.self)
        try container.encode(self.records, forKey: Card.RecordSet.CodingKeys.records)
        try container.encode(self.cost, forKey: Card.RecordSet.CodingKeys.cost)
    }
}
