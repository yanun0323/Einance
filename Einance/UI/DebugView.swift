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
    
    var body: some View {
        VStack {
            ViewHeader(title: "DEBUG")
            Spacer()
            VStack {
                Text("INFO")
                Text("Budget Count: \(budgetCount)")
                Text("Card Count: \(cardCount)")
                Text("Record Count: \(recordCount)")
                VStack(spacing: 15) {
                    Text("\(date)\n\(date.String(.Stamp, .US))\n\(date.String(.Stamp, .US))")
                    Text("\(Date(date.unixDay))\n\(Date(date.unixDay).String(.Stamp, .US))\n\(Date(date.unixDay).String(.Stamp, .US))")
                }
            }
            Divider()
            
            anyButton("Delete Last Budget") {
                container.interactor.data.DebugDeleteLastBudget()
            }
            
            anyButton("Force Monthly Update") {
                container.interactor.data.UpdateMonthlyBudget(budget)
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
