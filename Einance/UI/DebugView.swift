import SwiftUI
import UIComponent
import SQLite

struct DebugView: SwiftUI.View {
    @EnvironmentObject private var container: DIContainer
    @State private var trigger: Bool = false
    @State private var budgetCount: Int = 0
    @State private var cardCount: Int = 0
    @State private var recordCount: Int = 0
    @State private var tagCount: Int = 0
    @State private var date: Date = Date(from: "20220101", .Numeric)!
    @State private var tags: [Tag] = []
    
    @ObservedObject var budget: Budget
    
    @State private var TODO: [String] = [
        "~計算機",
        "強制更新卡片(調到之前的日期，顯示應為之後的)",
        "強制更新卡片(同一天不能重複更新)check db budget start date exist?",
        "~修改record 標籤要跟著 picked date",
        "歷史圖表",
        "統計圖表",
        "定時清Tag功能(每天清'一個月'沒更新的？)",
        "隨後備註功能",
        "排查重開閃退資料遺失問題",
        "[訂閱] 串接雲端發票",
        "[訂閱] 雲端發票移動",
        "[訂閱] 卡片系統上線",
        "[訂閱] 圖片功能",
    ]
    
    var body: some SwiftUI.View {
        VStack {
            ViewHeader(title: "DEBUG")
            Spacer()
            VStack {
                VStack(spacing: 5) {
                    Text("要做的事")
                        .font(.system(.title2, weight: .bold))
                        .padding(5)
                    ScrollView(.vertical, showsIndicators: true) {
                        LazyVStack(alignment: .leading, spacing: 5) {
                            ForEach(TODO, id: \.self) { todo in
                                Text("- \(todo)")
                                    .foregroundColor(todo.first == "~" ? .section : .primary75)
                                    .font(.callout)
                            }
                            
                            Block(height: 10)
                            
                            ForEach(tags, id: \.self) { t in
                                Text("ID: \(t.id), Value: \(t.value), Ts: \(t.UpdatedAti), Type: \(t.type.rawValue), Count: \(t.count), ChainID: \(t.chainID) ")
                            }
                        }
                    }
                }
                .padding(.horizontal)
                Divider()
                Text("Budget Count: \(budgetCount)")
                Text("Card Count: \(cardCount)")
                Text("Record Count: \(recordCount)")
                Text("Tag Count: \(tagCount)")
            }
            Divider()
            
            VStack {
                anyButton("Force Refresh") {
                    container.interactor.data.PublishCurrentBudget()
                }
                
                anyButton("Delete All Tags") {
                    System.Catch("DELETE ALL TAGS") {
                        let query = Tag.Table().delete()
                        try Sql.GetDriver().run(query)
                    }
                }
                
                anyButton("Regen Card ChainID") {
                    System.Catch("Regen Card ChainID") {
                        try budget.book.forEach { c in
                            c.chainID = UUID()
                            try container.interactor.data.Repo().UpdateCard(c)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .onAppear {
            refreshInfo()
        }
        .onChange(of: trigger) { _ in
            refreshInfo()
        }
        .backgroundColor(.background)
    }
    
    @ViewBuilder
    private func anyButton(_ title: String, _ color: Color = .gray, _ action: @escaping () -> Void) -> some SwiftUI.View {
        ButtonCustom(width: 200, height: 50, color: color, radius: 5, shadow: 3) {
            withAnimation(.quick) {
                trigger.toggle()
                action()
            }
        } content: {
            Text(title)
                .foregroundColor(.white)
        }
    }
}

extension DebugView {
    func refreshInfo() {
        System.Catch("[DEBUG] refresh info") {
            let db = Sql.GetDriver()
            
            recordCount = try db.scalar(Record.Table().count)
            cardCount = try db.scalar(Card.Table().count)
            budgetCount = try db.scalar(Budget.Table().count)
            tagCount = try db.scalar(Tag.Table().count)
            return
            let rows = try db.prepare(Tag.Table())
            for r in rows {
                tags.append(try parseTag(r))
            }
        }
    }
    
    private func parseTag(_ row: Row) throws -> Tag {
        return Tag(
            id: try row.get(Tag.id),
            chainID: try row.get(Tag.chainID),
            type: try row.get(Tag.type),
            value: try row.get(Tag.value),
            count: try row.get(Tag.count),
            updatedAti: try row.get(Tag.updatedAti))
    }
}

struct DebugView_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        DebugView(budget: .preview)
            .inject(DIContainer.preview)
    }
}
