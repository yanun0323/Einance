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
                container.interactor.system.PushRouterView(SettingView(budget: budget, current: current))
            } content: {
                Image(systemName: "gearshape")
                    .font(.title2)
            }
            ButtonCustom(width: buttonSize, height: buttonSize) {
                container.interactor.system.PushRouterView(StatisticView(budget: budget, card: current))
            } content: {
                Image(systemName: "chart.pie")
                    .font(.title2)
            }
            Spacer()
#if DEBUG
            ButtonCustom(width: buttonSize, height: buttonSize) {
                container.interactor.system.PushRouterView(DebugView(budget: budget))
            } content: {
                Image(systemName: "hammer.fill")
                    .font(.title2)
            }
            Spacer()
#endif
            ButtonCustom(width: buttonSize, height: buttonSize) {
                container.interactor.system.PushRouterView(BookOrderView(budget: budget))
            } content: {
                Image(systemName: "rectangle.on.rectangle.angled")
                    .font(.title2)
            }

            ButtonCustom(width: buttonSize, height: buttonSize) {
                container.interactor.system.PushActionView(CreateCardPanel(budget: budget))
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
