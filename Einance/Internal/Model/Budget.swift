//
//  Budget.swift
//  Einance
//
//  Created by YanunYang on 2022/11/10.
//

import Foundation

final class Budget {
    var uuid: UUID
    var start: Date
    var book: [Card]
    
    /* Cache */
    var amount: Decimal
    var balance: Decimal
    var cost: Decimal
    
    init(uuid: UUID = .init(), start: Date, book: [Card] = []) {
        self.uuid = uuid
        self.start = start
        self.book = book
        self.amount = 0
        self.balance = 0
        self.cost = 0
        
        for card in book {
            amount += card.amount
            cost += card.cost
        }
        balance = amount - balance
    }
}

extension Budget: Identifiable {}
