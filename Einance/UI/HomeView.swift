import SwiftUI
import UIComponent

struct HomeView: View {
    @EnvironmentObject private var container: DIContainer
    @State private var hideAddButton: Bool = false
    
    @ObservedObject var current: Current
    
    var body: some View {
        ZStack {
            VStack {
                HomeHeader(current: current)
                    .padding(.horizontal)
                
                if hasCards {
                    BudgetPage(current: current)
                } else {
                    Spacer()
                    ButtonCustom(width: 100, height: 100) {
                        container.interactor.system.PushActionView(current: current)
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
                    AddRecordButton(current: current)
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
        current.budget.book.count != 0
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(current: .preview)
            .inject(DIContainer.preview)
    }
}
