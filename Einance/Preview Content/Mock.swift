import SwiftUI
import UIComponent

extension DIContainer {
    static var preview: DIContainer {
        DIContainer(isMock: true)
    }
}

extension Budget {
    static var preview: Budget {
        Budget(start: Date(from: "20221105", .Numeric)!, book: [
            .preview,
            .preview2,
        ])
    }
}

extension Card {
    static var preview: Card {
        Card(name: "伙食費", amount: 1500, records: [
            Record(date: Date(from: "20221110", .Numeric)!, cost: 50, memo: "早餐"),
            Record(date: Date(from: "20221110", .Numeric)!, cost: 120, memo: "雞腿便當"),
            Record(date: Date(from: "20221111", .Numeric)!, cost: 35, memo: "黑豆漿"),
            Record(date: Date(from: "20221113", .Numeric)!, cost: 150, memo: "摩斯漢堡"),
        ], color: .cyan)
    }
    
    static var preview2: Card {
        Card(name: "債務", amount: 0, display: .forever, records: [
            Record(date: Date(from: "20221106", .Numeric)!, cost: 70, memo: "五十嵐"),
            Record(date: Date(from: "20221108", .Numeric)!, cost: 113, memo: "7-11"),
            Record(date: Date(from: "20221117", .Numeric)!, cost: 183, memo: "摩斯漢堡"),
        ], color: .orange)
    }
}

extension Record {
    static var preview: Record {
        Record(date: Date(from: "20221110", .Numeric)!, cost: 500, memo: "隨邊買個東西")
    }
}
