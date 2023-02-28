import SwiftUI
import UIComponent

struct AddRecordButton: View {
    @EnvironmentObject private var container: DIContainer
    @Binding var current: Card
    @Binding var color: Color
    
    var body: some View {
        Button {
            container.interactor.system.PushActionView(CreateRecordPanel(today: .now, isForever: current.display == .forever))
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
        AddRecordButton(current: .constant(.preview), color: .constant(.red))
            .inject(DIContainer.preview)
    }
}
