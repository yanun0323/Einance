import SwiftUI
import UIComponent

struct ActionPanelCloseButton: View {
    @EnvironmentObject private var container: DIContainer
    private var size: CGFloat = 25
    
    var body: some View {
        Button {
            container.interactor.system.ClearActionView()
        } label: {
            Image(systemName: "multiply")
                .font(.system(size: size, weight: .light))
                .foregroundColor(.primary)
        }
    }
}

#if DEBUG
struct ActionViewCloseButton_Previews: PreviewProvider {
    static var previews: some View {
        ActionPanelCloseButton()
            .inject(DIContainer.preview)
    }
}
#endif
