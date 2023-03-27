import SwiftUI
import UIComponent

struct HomeView: View {
    @EnvironmentObject private var container: DIContainer
    
    @ObservedObject var budget: Budget
    @ObservedObject var current: Card
    @Binding var selected: Card
    @Binding var showAddButton: Bool
    
    var body: some View {
        ZStack {
            budgetPageLayer()
                .ignoresSafeArea(.all, edges: .bottom)
            addRecordButtonLayer()
                .ignoresSafeArea(.all, edges: .bottom)
        }
    }
    
    @ViewBuilder
    private func budgetPageLayer() -> some View {
        VStack {
            HomeHeader(budget: budget, current: current)
                .padding(.horizontal)
            if budget.HasCard() {
                BudgetPage(budget: budget, current: current, selected: $selected)
            } else {
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private func addRecordButtonLayer() -> some View {
        VStack {
            Spacer()
            if budget.HasCard() && showAddButton {
                AddRecordButton(budget: budget, card: current)
                    .transition(.move(edge: .bottom))
            }
        }
    }
}

// MARK: - Function
extension HomeView {}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(budget: .preview, current: .preview, selected: .constant(.preview), showAddButton: .constant(true))
            .inject(DIContainer.preview)
            .previewDeviceSet()
    }
}
#endif
