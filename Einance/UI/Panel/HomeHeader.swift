import SwiftUI
import UIComponent

struct HomeHeader: View {
    @EnvironmentObject private var container: DIContainer
    let buttonSize: CGFloat = 40
    var body: some View {
        HStack {
            ButtonCustom(width: buttonSize, height: buttonSize) {
                container.interactor.system.PushRouterView(SettingView())
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
            ButtonCustom(width: buttonSize, height: buttonSize) {
                
            } content: {
                Image(systemName: "rectangle.on.rectangle.angled")
                    .font(.title2)
            }

            ButtonCustom(width: buttonSize, height: buttonSize) {
                container.interactor.system.PushActionView(CreateCardPanel())
            } content: {
                Image(systemName: "rectangle.fill.badge.plus")
                    .font(.title2)
            }
        }
        .foregroundColor(.gray)
    }
}

// MARK: - View Block
extension HomeHeader {
}

struct HomeHeader_Previews: PreviewProvider {
    static var previews: some View {
        HomeHeader()
            .inject(DIContainer.preview)
    }
}
