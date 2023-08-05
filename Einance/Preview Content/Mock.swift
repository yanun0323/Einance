import SwiftUI
import Ditto

#if DEBUG
extension DIContainer {
    static var preview = DIContainer(isMock: true)
}

extension Budget {
    static var preview = Budget(id: -1, startAt: Date(from: "20221105", .Numeric)!, book: [
            .preview,
            .preview2,
            .preview3,
            .preview4,
        ])
}

extension Card {
    static var preview = Card(id: -1, index: 0, name: "Food", amount: 1500, records: [
            Record(id: -1, date: Date(from: "20221110", .Numeric)!, cost: 50, memo: "Breakfast", pinned: true),
            Record(id: -2, date: Date(from: "20221110", .Numeric)!, cost: 120, memo: "lauch"),
            Record(id: -3, date: Date(from: "20221111", .Numeric)!, cost: 35, memo: "some drinks"),
            Record(id: -4, date: Date(from: "20221113", .Numeric)!, cost: 150, memo: "hamburger"),
            Record(id: -5, date: Date(from: "20221113", .Numeric)!, cost: 220, memo: "dinner"),
            Record(id: -6, date: Date(from: "20221113", .Numeric)!, cost: 80, memo: "anoter dinner"),
    ], fColor: Color(hex: "#cccccc"), bColor: .cyan, gColor: .green, pinned: true)
    
    static var preview2 = Card(id: -2, index: 1, name: "中文", amount: 0, display: .forever, records: [
            Record(id: -5, date: Date(from: "20221106", .Numeric)!, cost: 70, memo: "記錄一", pinned: true),
            Record(id: -6, date: Date(from: "20221110", .Numeric)!, cost: 113, memo: "記錄二"),
    ], bColor: .orange, gColor: .red, pinned: true)
    
    static var preview3 = Card(id: -3, index: 2, name: "very fucking long title name", amount: 10000, records: [], bColor: .green, gColor: .cyan, pinned: true)
    static var preview4 = Card(id: -4, index: 3, name: "whatever", amount: 12000, records: [
        Record(id: -7, date: Date(from: "20221106", .Numeric)!, cost: 7000, memo: "forgot"),
        Record(id: -8, date: Date(from: "20221120", .Numeric)!, cost: 1113, memo: "unknow"),
    ], bColor: .red, gColor: .green, pinned: true)
}

extension Record {
    static var preview = Record(id: -9, date: Date(from: "20221110", .Numeric)!, cost: 500, memo: "something")
}
#endif
