import SwiftUI

final class Record {
    var uuid: UUID
    var date: Date
    var cost: Decimal
    var memo: String
    
    init(uuid: UUID = .init(), date: Date = .now, cost: Decimal = 0, memo: String = "") {
        self.uuid = uuid
        self.date = date
        self.cost = cost
        self.memo = memo
    }
    
    init(_ mo: RecordMO) {
        self.uuid = mo.uuid
        self.date = mo.date
        self.cost = mo.cost as Decimal
        self.memo = mo.memo
    }
}

extension Record: Identifiable {}
