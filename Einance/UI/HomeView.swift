import SwiftUI

struct HomeView: View {
    @EnvironmentObject var container: DIContainer
    @State private var budget: Budget
    @State private var current: Card
    @State private var hideAddButton: Bool = false
    
    init(injector: DIContainer) {
        self.budget = injector.interactor.data.CurrentBudget()
        self.current = injector.interactor.data.CurrentCard()
    }
    
    var body: some View {
        ZStack {
            VStack {
                HomeHeader()
                    .padding(.horizontal)
                BudgetPage(budget: budget, current: $current)
            }
            VStack {
                Spacer()
                if !hideAddButton {
                    AddRecordButton(current: $current, color: $current.color)
                        .transition(.move(edge: .bottom))
                }
            }
            .ignoresSafeArea(.all)
        }
        .backgroundColor(.background)
        .onReceive(container.appstate.actionViewPublisher) { output in
            withAnimation {
                hideAddButton = (output != nil)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(injector: .preview)
            .inject(DIContainer.preview)
    }
}
