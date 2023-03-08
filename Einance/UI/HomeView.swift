import SwiftUI
import UIComponent

struct HomeView: View {
    @EnvironmentObject private var container: DIContainer
    @State private var hideAddButton: Bool = false
    
    @ObservedObject var budget: Budget
    @Binding var current: Card
    
    var body: some View {
        ZStack {
            VStack {
                HomeHeader(budget: budget, current: current)
                    .padding(.horizontal)
                
                if hasCards {
                    BudgetPage(budget: budget, current: $current)
                } else {
                    Spacer()
                    ButtonCustom(width: 100, height: 100) {
                        container.interactor.system.PushActionView(CreateCardPanel(budget: budget))
                    } content: {
                        Image(systemName: "rectangle.fill.badge.plus")
                            .font(.title)
                    }
                    Spacer()
                }
            }
            VStack {
                Spacer()
                if hasCards && !hideAddButton {
                    AddRecordButton(budget: budget, card: current)
                        .transition(.move(edge: .bottom))
                }
            }
            .ignoresSafeArea(.all)
        }
        .backgroundColor(.background)
        .onReceive(container.appstate.actionViewPublisher) { output in
            withAnimation(.quick) {
                hideAddButton = (output != nil)
            }
        }
    }
}

extension HomeView {
    var hasCards: Bool {
        budget.book.count != 0
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(budget: .preview, current: .constant(.preview))
            .inject(DIContainer.preview)
    }
}
