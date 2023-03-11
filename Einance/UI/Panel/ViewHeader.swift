import SwiftUI
import UIComponent

struct ViewHeader: View {
    @EnvironmentObject private var container: DIContainer
    let title: LocalizedStringKey
    let length: CGFloat = 45
    
    var body: some View {
        HStack {
            Block(width: length, height: length)
            Spacer()
            Text(title)
                .font(.title2)
            Spacer()
            ButtonCustom(width: length, height: length, radius: 10) {
                container.interactor.system.ClearRouterView()
            } content: {
                Image(systemName: "multiply")
                    .font(.title)
            }
        }
    }
}

struct ViewHeader_Previews: PreviewProvider {
    static var previews: some View {
        ViewHeader(title: "加入新的預算卡片")
            .inject(DIContainer.preview)
    }
}
