import SwiftUI
import UIComponent

struct DebugView: View {
    @EnvironmentObject private var container: DIContainer
    @State private var trigger: Bool = false
    @State private var budgetCount: Int = 0
    @State private var cardCount: Int = 0
    @State private var recordCount: Int = 0
    var body: some View {
        VStack {
            ViewHeader(title: "DEBUG")
            Spacer()
            VStack {
                Text("INFO")
                Text("Budget Count: \(budgetCount)")
                Text("Card Count: \(cardCount)")
                Text("Record Count: \(recordCount)")
            }
            Divider()
            
            anyButton("Create Budget") {
                container.interactor.data.DebugCreateBudget()
            }
            
            anyButton("Delete Budgets", .red) {
                container.interactor.data.DebugDeleteAllBudgets()
            }
            
            anyButton("Refresh Info") {
                refreshInfo()
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
            withAnimation {
                trigger.toggle()
                action()
            }
        } content: {
            Text(title)
                .foregroundColor(.white)
        }
    }
    
    func refreshInfo() {
        System.Invoke("[DEBUG] refresh info") {
            let db = Sql.GetDriver()
            
            recordCount = try db.scalar(Record.GetTable().count)
            cardCount = try db.scalar(Card.GetTable().count)
            budgetCount = try db.scalar(Budget.GetTable().count)
        }
    }
}

struct DebugView_Previews: PreviewProvider {
    static var previews: some View {
        DebugView()
            .inject(DIContainer.preview)
    }
}
