import Ditto
import SQLite
import SwiftUI
import Sworm

struct DebugView: SwiftUI.View {
    @Environment(\.injected) private var container: DIContainer
    @State private var trigger: Bool = false
    @State private var budgetCount: Int = 0
    @State private var cardCount: Int = 0
    @State private var recordCount: Int = 0
    @State private var tagCount: Int = 0
    @State private var date: Date = Date(from: "20220101", .Numeric)!
    @State private var tags: [Tag] = []
    @State private var cards: [Card] = []
    @State private var records: [Record] = []
    @State private var infos: [String] = []

    @ObservedObject var budget: Budget

    @State private var TODO: [String] = [
        "教學畫面",
        "隨後備註功能",
        "[訂閱] 串接雲端發票",
        "[訂閱] 雲端發票移動",
        "[訂閱] 卡片系統上限",
        "[訂閱] 圖片功能",
        "~歷史圖表",
        "~統計圖表",
        "~強制更新卡片(調到之前的日期，顯示應為之後的)",
        "~Setting Localized",
        "~計算機",
        "~Card Name Color",
        "~強制更新卡片(同一天不能重複更新)",
        "~修改record 標籤要跟著 picked date",
        "~定時清Tag功能(每天清'一個月'沒更新的？)",
        "~排查重開閃退資料遺失問題",
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
                            
                            ForEach(infos, id: \.self) { info in
                                Text(info)
                            }
                            
                            Divider()
                            
                            ForEach(cards) { c in
                                Text("Card ID: \(c.id), BudgetID: \(c.budgetID), Name: \(c.name)")
                            }
                            
                            Divider()
                            
                            ForEach(records) { r in
                                Text("Record ID: \(r.id), CardID: \(r.cardID), Memo: \(r.memo),")
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Divider()
                VStack {
                    Text("Budget Count: \(budgetCount)")
                    Text("Budget At: \(budget.startAt.string("yyyy.MM.dd"))")
                    Text("Card Count: \(cardCount)")
                    Text("Record Count: \(recordCount)")
                    Text("Tag Count: \(tagCount)")
                    Text("DB: \(UserDefaults.mockDBName ?? "development")")
                }
            }
            Divider()
            VStack {
                anyButton("PublishCurrentBudgetFromDB") {
                    container.interactor.data.PublishCurrentBudgetFromDB()
                }
                
                anyButton("fetch Cards") {
                    cards = container.interactor.data.ListAllCard()
                }
                
                anyButton("DeleteLastBudget", .red) {
                    deleteLastBudget()
                }

                if UserDefaults.mockDBName != "development" {
                    anyButton("Delete All Budget") {
                        System.doCatch("DELETE ALL") {
                            let db = SQL.getDriver()
                            _ = try db.run(Tag.table.delete())
                            _ = try db.run(Record.table.delete())
                            _ = try db.run(Card.table.delete())
                            _ = try db.run(Budget.table.delete())
                        }
                    }
                }

                anyButton("Switch DB") {
                    if UserDefaults.mockDBName != "development" {
                        UserDefaults.mockDBName = "development"
                    } else {
                        UserDefaults.mockDBName = "test"
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
    private func anyButton(_ title: String, _ color: Color = .gray, _ action: @escaping () -> Void)
        -> some SwiftUI.View
    {
        Button(width: 200, height: 50, color: color, radius: 5) {
            withAnimation(.quick) {
                trigger.toggle()
                action()
            }
        } content: {
            Text(title)
                .foregroundColor(.white)
        }
        .shadow(radius: 3)
    }
}

extension DebugView {
    func refreshInfo() {
        System.doCatch("[DEBUG] refresh info") {
            let db = SQL.getDriver()

            recordCount = try db.scalar(Record.table.count)
            cardCount = try db.scalar(Card.table.count)
            budgetCount = try db.scalar(Budget.table.count)
            tagCount = try db.scalar(Tag.table.count)
            
            let rows = try db.prepare(Tag.table.order(Tag.id))
            for r in rows {
                tags.append(try Tag.parse(r))
            }
            
            let rows2 = try db.prepare(Record.table.order(Record.id))
            for r in rows2 {
                records.append(try Record.parse(r))
            }
            
            cards = container.interactor.data.ListAllCard()
        }
    }

    private func parseTag(_ row: Row) throws -> Tag {
        return Tag(
            id: try row.get(Tag.id),
            chainID: try row.get(Tag.chainID),
            type: try row.get(Tag.type),
            value: try row.get(Tag.value),
            count: try row.get(Tag.count),
            key: try row.get(Tag.key)
        )
    }

    private func deleteLastBudget() {
        System.doCatch("[DEBUG] delete last budget") {
            guard let b = container.interactor.data.GetCurrentBudget() else {
                throw Err.budgetNotFound
            }
            try SQL.getDriver().run(Budget.table.where(Budget.id == b.id).delete())
            print("[DEBUG] last budget: (\(b.id)), has been delete")
            container.interactor.data.PublishCurrentBudgetFromDB()
        }
    }
}

struct DebugView_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        DebugView(budget: .preview)
            .inject(DIContainer.preview)
    }
}
