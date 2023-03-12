import SwiftUI
import UIComponent

struct HomeView: View {
    @EnvironmentObject private var container: DIContainer
    @State private var showAddButton: Bool = false
    
    @ObservedObject var budget: Budget
    @ObservedObject var current: Card
    @Binding var selected: Card
    
    var body: some View {
        ZStack {
            VStack {
                HomeHeader(budget: budget, current: current)
                    .padding(.horizontal)
                
                if hasCards {
                    BudgetPage(budget: budget, current: current, selected: $selected)
                } else {
                    VStack {
                        Spacer()
                        ButtonCustom(width: 100, height: 100) {
                            container.interactor.system.PushActionView(.CreateCard(budget))
                        } content: {
                            Image(systemName: "rectangle.fill.badge.plus")
                                .font(.title)
                        }
                        Spacer()
                    }
                }
            }
            VStack {
                Spacer()
                if hasCards && showAddButton {
                    AddRecordButton(budget: budget, card: current)
                        .transition(.move(edge: .bottom))
                }
            }
            .ignoresSafeArea(.all)
        }
        .ignoresSafeArea(.keyboard)
        .onReceive(container.appstate.actionViewEmptyPublisher) { showAddButton = $0 }
        .animation(.quick, value: showAddButton)
    }
}

extension HomeView {
    var hasCards: Bool {
        budget.book.count != 0
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(budget: .preview, current: .preview, selected: .constant(.preview))
            .inject(DIContainer.preview)
            .previewDeviceSet()
    }
}
