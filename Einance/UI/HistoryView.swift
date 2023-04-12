import SwiftUI
import UIComponent

struct HistoryView: View {
    @EnvironmentObject private var container: DIContainer
    @State private var budgets: [Budget] = []
    @State private var budget: Budget? = nil
    
    init() {
        UINavigationBar.appearance().backgroundColor = UIColor(Color.background)
    }
    
    var body: some View {
        VStack {
            ViewHeader(title: "view.header.history")
            ZStack {
                budgetsScrollBlock()
                budgetStatisticBlock()
            }
            Spacer()
        }
        .modifyRouterBackground()
        .transition(.scale(scale: 0.95, anchor: .topLeading).combined(with: .opacity))
        .onAppeared { budgets = container.interactor.data.ListBudgets() }
    }
    
    @ViewBuilder
    private func budgetRowBlock(_ b: Budget) -> some View {
        Button {
            withAnimation(.quick) {
                budget = b
            }
        } label: {
            HStack {
                Image(systemName: "square.stack.3d.down.forward")
                Text(b.startAt.String("yyyy.MM.dd"))
                Text(b.amount.description)
            }
            .font(.system(.title3))
            .foregroundColor(.primary75)
            .padding(5)
            .backgroundColor(.transparent)
        }

    }
    
    @ViewBuilder
    private func budgetsScrollBlock() -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            ForEach(budgets) { b in
                budgetRowBlock(b)
            }
        }
        .monospacedDigit()
    }
    
    @ViewBuilder
    private func budgetStatisticBlock() -> some View {
        VStack {
            if let b = budget {
                VStack {
                    Button {
                        withAnimation(.quick) {
                            budget = nil
                        }
                    } label: {
                        Text("back")
                            .padding(5)
                            .backgroundColor(.transparent)
                    }
                    
                    StatisticPage(budget: b)
                }
                .backgroundColor(.background)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .offset(x: budget.isNil ? System.device.screen.width : 0)
    }
    
}

#if DEBUG
struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
            .inject(DIContainer.preview)
    }
}
#endif
