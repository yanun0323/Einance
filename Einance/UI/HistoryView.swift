import SwiftUI
import UIComponent

struct HistoryView: View {
    @EnvironmentObject private var container: DIContainer
    @State private var budgets: [Budget] = []
    
    var body: some View {
        VStack {
            ViewHeader(title: "view.header.history")
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack {
                    ForEach(budgets) {
                        budgetRowBlock($0)
                    }
                }
            }
            Spacer()
        }
        .modifyRouterBackground()
        .transition(.scale(scale: 0.95, anchor: .topLeading).combined(with: .opacity))
        .onAppeared { budgets = container.interactor.data.ListBudgets() }
    }
    
    @ViewBuilder
    private func budgetRowBlock(_ b: Budget) -> some View {
        HStack {
            Text(b.startAt.String("yyyy.MM.dd"))
            Text(b.book.count.description)
            Text(b.amount.description)
        }
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
