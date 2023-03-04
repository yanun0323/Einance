import SwiftUI
import UIComponent

struct HomeHeader: View {
    @EnvironmentObject private var container: DIContainer
    @ObservedObject var current: Current
    
    let buttonSize: CGFloat = 40
    var body: some View {
        HStack {
            ButtonCustom(width: buttonSize, height: buttonSize) {
                container.interactor.system.PushRouterView(SettingView(current: current))
            } content: {
                Image(systemName: "gearshape")
                    .font(.title2)
            }
            ButtonCustom(width: buttonSize, height: buttonSize) {
            } content: {
                Image(systemName: "chart.xyaxis.line")
                    .font(.title2)
            }
            Spacer()
#if DEBUG
            ButtonCustom(width: buttonSize, height: buttonSize) {
                container.interactor.system.PushRouterView(DebugView())
            } content: {
                Image(systemName: "hammer.fill")
                    .font(.title2)
            }
            Spacer()
#endif
            ButtonCustom(width: buttonSize, height: buttonSize) {
                
            } content: {
                Image(systemName: "rectangle.on.rectangle.angled")
                    .font(.title2)
            }

            ButtonCustom(width: buttonSize, height: buttonSize) {
                container.interactor.system.PushActionView(CreateCardPanel(current: current))
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
        HomeHeader(current: .preview)
            .inject(DIContainer.preview)
    }
}
