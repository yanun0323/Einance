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
                container.interactor.system.PushRouterView(RouterView(budget: budget, current: current, router: .Setting))
            } content: {
                Image(systemName: "gearshape")
                    .font(.title2)
            }
            ButtonCustom(width: buttonSize, height: buttonSize) {
                container.interactor.system.PushRouterView(RouterView(budget: budget, current: current, router: .Statistic))
            } content: {
                Image(systemName: "chart.pie")
                    .font(.title2)
            }
            Spacer()
#if DEBUG
            ButtonCustom(width: buttonSize, height: buttonSize) {
                container.interactor.system.PushRouterView(RouterView(budget: budget, router: .Debug))
            } content: {
                Image(systemName: "hammer.fill")
                    .font(.title2)
            }
            Spacer()
#endif
            if budget.book.count >= 2 {
                ButtonCustom(width: buttonSize, height: buttonSize) {
                    container.interactor.system.PushRouterView(RouterView(budget: budget, router: .BookOrder))
                } content: {
                    Image(systemName: "rectangle.on.rectangle.angled")
                        .font(.title2)
                }
            } else {
                Block(width: buttonSize, height: buttonSize)
            }

            ButtonCustom(width: buttonSize, height: buttonSize) {
                container.interactor.system.PushActionView(ActionView(budget: budget, router: .CreateCard))
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
