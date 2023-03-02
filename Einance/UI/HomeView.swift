import SwiftUI
import UIComponent

struct HomeView: View {
    @EnvironmentObject var container: DIContainer
    @State private var budget: Budget
    @State private var card: Card = .preview
    @State private var cardExist: Bool = false
    @State private var hideAddButton: Bool = false
    
    init(injector: DIContainer) {
        self.budget = injector.interactor.data.CurrentBudget()
    }
    
    var body: some View {
        ZStack {
            VStack {
                HomeHeader()
                    .padding(.horizontal)
                
                if cardExist {
                    BudgetPage(budget: budget, current: $card)
                } else {
                    Spacer()
                    ButtonCustom(width: 100, height: 100) {
                        container.interactor.system.PushActionView(CreateCardPanel())
                    } content: {
                        Image(systemName: "rectangle.fill.badge.plus")
                            .font(.title)
                    }
                    Spacer()
                }
            }
            VStack {
                Spacer()
                if cardExist && !hideAddButton {
                    AddRecordButton(current: $card, color: $card.color)
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
        .onReceive(container.appstate.updateBudgetIDPublisher) { id in
            withAnimation {
                if let b = container.interactor.data.GetBudget(id) {
                    cardExist = b.book.count != 0
                    if cardExist { card = b.book[0] }
                    budget = b
                }
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
