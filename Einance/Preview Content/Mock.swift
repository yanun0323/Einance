import SwiftUI
import UIComponent

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
    static var preview = Card(id: -1, index: 0, name: "伙食費", amount: 1500, records: [
            Record(id: -1, date: Date(from: "20221110", .Numeric)!, cost: 50, memo: "早餐", fixed: true),
            Record(id: -2, date: Date(from: "20221110", .Numeric)!, cost: 120, memo: "雞腿便當"),
            Record(id: -3, date: Date(from: "20221111", .Numeric)!, cost: 35, memo: "黑豆漿"),
            Record(id: -4, date: Date(from: "20221113", .Numeric)!, cost: 150, memo: "摩斯漢堡"),
        ], fontColor: Color(hex: "#cccccc"), color: .cyan, fixed: true)
    
    static var preview2 = Card(id: -2, index: 1, name: "債務", amount: 0, display: .forever, records: [
            Record(id: -5, date: Date(from: "20221106", .Numeric)!, cost: 70, memo: "五十嵐", fixed: true),
            Record(id: -6, date: Date(from: "20221110", .Numeric)!, cost: 113, memo: "7-11"),
        ], color: .orange, fixed: true)
    
    static var preview3 = Card(id: -3, index: 2, name: "我的名字有夠他媽的長哈哈哈哈", amount: 10000, records: [], color: .green, fixed: true)
    static var preview4 = Card(id: -4, index: 3, name: "隨便打打", amount: 12000, records: [
        Record(id: -7, date: Date(from: "20221106", .Numeric)!, cost: 7000, memo: "忘記了"),
        Record(id: -8, date: Date(from: "20221120", .Numeric)!, cost: 1113, memo: "不知道"),
    ], color: .red, fixed: true)
}

extension Record {
    static var preview = Record(id: -9, date: Date(from: "20221110", .Numeric)!, cost: 500, memo: "隨邊買個東西")
}
#endif
