import SwiftUI
import UIComponent

struct HomeHeader: View {
    @EnvironmentObject private var container: DIContainer
    @ObservedObject var budget: Budget
    @ObservedObject var current: Card
    
    let buttonSize: CGFloat = 40
    var body: some View {
        HStack {
            ButtonCustom(width: buttonSize, height: buttonSize) {
                container.interactor.system.PushRouterView(.Setting(container, budget, current))
            } content: {
                Image(systemName: "gearshape")
                    .font(.title2)
            }
            ButtonCustom(width: buttonSize, height: buttonSize) {
                container.interactor.system.PushRouterView(.History)
            } content: {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.title2)
            }
            Spacer()
            
            if budget.book.count >= 2 {
                ButtonCustom(width: buttonSize, height: buttonSize) {
                    container.interactor.system.PushRouterView(.BookOrder(budget))
                } content: {
                    Image(systemName: "rectangle.stack")
                        .font(.title2)
                }
            } else {
                Block(width: buttonSize, height: buttonSize)
            }

            ButtonCustom(width: buttonSize, height: buttonSize) {
                container.interactor.system.PushActionView(.CreateCard(budget))
            } content: {
                Image(systemName: "rectangle.fill.badge.plus")
                    .font(.title2)
            }
        }
        .foregroundColor(.gray)
    }
}

// MARK: - View Block
extension HomeHeader {}

struct HomeHeader_Previews: PreviewProvider {
    static var previews: some View {
        HomeHeader(budget: .preview, current: .preview)
            .inject(DIContainer.preview)
        
        HomeHeader(budget: .preview, current: .preview)
            .inject(DIContainer.preview)
            .preferredColorScheme(.dark)
    }
}
