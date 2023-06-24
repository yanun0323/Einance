import SQLite
import SwiftUI

final class Record: ObservableObject {
    var id: Int64
    var cardID: Int64
    
    @Published var date: Date
    @Published var cost: Decimal
    @Published var memo: String
    @Published var pinned: Bool

    init(
        id: Int64 = 0,
        cardID: Int64 = 0,
        date: Date = .now,
        cost: Decimal = 0,
        memo: String = "",
        pinned: Bool = false
    ) {
        self.id = id
        self.cardID = cardID
        self.date = date
        self.cost = cost
        self.memo = memo
        self.pinned = pinned
    }
}

extension Record: Identifiable {}

extension Record {
    static func blank() -> Record { Record(id: -1, cardID: -1) }
    func isBlank() -> Bool { self.id == -1 }
}

extension Record: Codable {
    enum CodingKeys: CodingKey {
        case id
        case cardID
        case date
        case cost
        case memo
        case pinned
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.cardID, forKey: .cardID)
        try container.encode(self.date, forKey: .date)
        try container.encode(self.cost, forKey: .cost)
        try container.encode(self.memo, forKey: .memo)
        try container.encode(self.pinned, forKey: .pinned)
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(Int64.self, forKey: .id)
        let cardID = try container.decode(Int64.self, forKey: .cardID)
        let date = try container.decode(Date.self, forKey: .date)
        let cost = try container.decode(Decimal.self, forKey: .cost)
        let memo = try container.decode(String.self, forKey: .memo)
        let pinned = try container.decode(Bool.self, forKey: .pinned)
        self.init(id: id, cardID: cardID, date: date, cost: cost, memo: memo, pinned: pinned)
    }
}
