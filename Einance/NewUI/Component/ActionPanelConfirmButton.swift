import SwiftUI
import Ditto

struct ActionPanelConfirmButton: View {
    @Binding var color: Color
    var text: LocalizedStringKey
    var action: () -> Void
    
    var body: some View {
        Button(width: 0, height: Setting.panelCreateButtonHeight, action: action) {
            Text(text)
                .font(Setting.cardPanelInputFont)
                .foregroundColor(color)
        }
        .padding(10)
    }
}

#if DEBUG
struct ActionPanelConfirmButton_Previews: PreviewProvider {
    static var previews: some View {
        ActionPanelConfirmButton(color: .constant(.red), text: "global.create") {}
    }
}
#endif
