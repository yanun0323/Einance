import SwiftUI
import UIComponent

struct HomeView: View {
    @EnvironmentObject private var container: DIContainer
    
    @ObservedObject var budget: Budget
    @ObservedObject var current: Card
    @Binding var selected: Card
    
    var body: some View {
        ZStack {
            budgetPageLayer()
                .ignoresSafeArea(.all, edges: .bottom)
            AddRecordButtonLayer(budget: budget, card: current)
                .ignoresSafeArea(.all, edges: .bottom)
        }
        .ignoresSafeArea(.all, edges: .bottom)
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
}

// MARK: - Function
extension HomeView {}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(budget: .preview, current: .preview, selected: .constant(.preview))
            .inject(DIContainer.preview)
            .previewDeviceSet()
            .environment(\.locale, .US)
    }
}
#endif
