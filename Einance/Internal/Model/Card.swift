//
//  Card.swift
//  Einance
//
//  Created by YanunYang on 2022/11/10.
//

import SwiftUI

final class Card {
    var uuid: UUID
    var index: Int
    var name: String
    var amount: Decimal
    var display: Card.Display
    var records: [Record]
    var forever: Bool
    var color: Color
    
    /* Cache */
    var cost: Decimal
    var balance: Decimal
    
    init(uuid: UUID = .init(), index: Int = 0, name: String, amount: Decimal, display: Card.Display = .month, records: [Record] = [], forever: Bool = false, color: Color) {
        self.uuid = uuid
        self.index = index
        self.name = name
        self.amount = amount
        self.display = display
        self.records = records
        self.forever = forever
        self.color = color
        
        self.cost = 0
        self.balance = 0
        for record in records {
            self.cost += record.cost
        }
        self.balance = self.amount - self.cost
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
        if forever {
            return "card.display.forever"
        }
        return display.string
    }
}

// MARK: - Function
extension Card {}

// MARK: - Card.Display
extension Card {
    enum Display: Int {
        case day, week, month
        
        var string: LocalizedStringKey {
            switch self {
            case .day:
                return "card.display.day"
            case .week:
                return "card.display.week"
            case .month:
                return "card.display.month"
            }
        }
    }
}
