import SwiftUI
import UIComponent

struct AddRecordButton: View {
    @EnvironmentObject private var container: DIContainer
    @ObservedObject var current: Current
    @Binding var card: Card
    @Binding var color: Color
    
    var body: some View {
        Button {
            container.interactor.system.PushActionView(CreateRecordPanel(budget: budget, card: card))
        } label: {
            RoundedRectangle(cornerRadius: Setting.deviceCornerRadius)
                .frame(height: 90)
                .foregroundColor(.background)
                .shadow(radius: 5)
                .overlay {
                    Label("button.record.create", systemImage: "plus.square.dashed")
                        .font(.system(size: 28, weight: .light))
                        .kerning(2)
                        .foregroundColor(color)
                        .padding(size*0.15)
                        .padding(.bottom)
                }
        }
    }
}

// MARK: - Property
extension AddRecordButton {
    var size: CGFloat {
        System.device.screen.width*0.2
    }
}

struct AddRecordButton_Previews: PreviewProvider {
    static var previews: some View {
        AddRecordButton(budget: .preview, card: .constant(.preview), color: .constant(.red))
            .inject(DIContainer.preview)
    }
}
