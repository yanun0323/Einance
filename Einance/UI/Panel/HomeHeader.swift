import SwiftUI
import UIComponent

struct HomeHeader: View {
    @EnvironmentObject private var container: DIContainer
    @ObservedObject var budget: Budget
    @ObservedObject var current: Card
    
    let buttonSize: CGFloat = 40
    var body: some View {
        HStack {
            settingButton()
            analysisButton()
            Spacer()
            #if DEBUG
            debugButton()
            Spacer()
            #endif
            reorderButton()
            createCardButton()
        }
        .foregroundColor(.gray)
    }
    
    @ViewBuilder
    private func settingButton() -> some View {
        ButtonCustom(width: buttonSize, height: buttonSize) {
            container.interactor.system.PushRouterView(.Setting(container, budget, current))
        } content: {
            Image(systemName: "gearshape")
                .font(.title2)
        }
    }
    
    @ViewBuilder
    private func analysisButton() -> some View {
        ButtonCustom(width: buttonSize, height: buttonSize) {
            container.interactor.system.PushRouterView(.Analysis)
        } content: {
            Image(systemName: "chart.xyaxis.line")
                .font(.title2)
        }
    }
    
    @ViewBuilder
    private func reorderButton() -> some View {
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
    }
    
    @ViewBuilder
    private func createCardButton() -> some View {
        ButtonCustom(width: buttonSize, height: buttonSize) {
            container.interactor.system.PushActionView(.CreateCard(budget))
        } content: {
            Image(systemName: "rectangle.fill.badge.plus")
                .font(.title2)
        }
    }
    
    @ViewBuilder
    private func debugButton() -> some View {
        ButtonCustom(width: buttonSize, height: buttonSize) {
            container.interactor.system.PushRouterView(.Debug(budget))
        } content: {
            Image(systemName: "hammer")
                .font(.title2)
        }
    }
}

#if DEBUG
struct HomeHeader_Previews: PreviewProvider {
    static var previews: some View {
        HomeHeader(budget: .preview, current: .preview)
            .inject(DIContainer.preview)
        
        HomeHeader(budget: .preview, current: .preview)
            .inject(DIContainer.preview)
            .preferredColorScheme(.dark)
    }
}
#endif
