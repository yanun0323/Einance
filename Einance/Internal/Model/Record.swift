//
//  Record.swift
//  Einance
//
//  Created by YanunYang on 2022/11/10.
//

import Foundation

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
}

extension Record: Identifiable {}
