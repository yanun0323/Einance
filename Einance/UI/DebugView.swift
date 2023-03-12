import SwiftUI
import UIComponent

struct DebugView: View {
    @EnvironmentObject private var container: DIContainer
    @State private var trigger: Bool = false
    @State private var budgetCount: Int = 0
    @State private var cardCount: Int = 0
    @State private var recordCount: Int = 0
    @State private var date: Date = Date(from: "20220101", .Numeric)!
    
    @ObservedObject var budget: Budget
    
    @State private var TODO: [String] = [
        "Budget 要新增一欄 archiveAt",
        "Card 要新增 startAt & archiveAt 來判斷永久卡片的起始",
        "修鍵盤會讓畫面位移問題",
        "統計圖表",
        "*串接雲端發票",
        "*花費位移系統/卡片接收雲端發票Filter",
        "*",
    ]
    
    var body: some View {
        VStack {
            ViewHeader(title: "DEBUG")
            Spacer()
            VStack {
                VStack(spacing: 5) {
                    Text("要做的事")
                    ForEach(TODO, id: \.self) { todo in
                        Text(todo)
                            
                    }
                    .font(.caption)
                    .foregroundColor(.cyan)
                }
                Divider()
                Text("Budget Count: \(budgetCount)")
                Text("Card Count: \(cardCount)")
                Text("Record Count: \(recordCount)")
            }
            Divider()
            
            anyButton("Delete Last Budget") {
                container.interactor.data.DebugDeleteLastBudget()
                container.interactor.data.PublishCurrentBudget()
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
    
    func anyButton(_ title: String, _ color: Color = .gray, _ action: @escaping () -> Void) -> some View {
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
    
    func refreshInfo() {
        System.Catch("[DEBUG] refresh info") {
            let db = Sql.GetDriver()
            
            recordCount = try db.scalar(Record.GetTable().count)
            cardCount = try db.scalar(Card.GetTable().count)
            budgetCount = try db.scalar(Budget.GetTable().count)
        }
    }
}

struct DebugView_Previews: PreviewProvider {
    static var previews: some View {
        DebugView(budget: .preview)
            .inject(DIContainer.preview)
    }
}
