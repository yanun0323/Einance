import SwiftUI

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
        balance = amount - cost
    }
}

extension Budget: Identifiable {}

extension Budget {}
