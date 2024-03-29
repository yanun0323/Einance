import SwiftUI
import UIComponent

struct AddRecordButtonLayer: View {
    @EnvironmentObject private var container: DIContainer
    
    @ObservedObject var budget: Budget
    @ObservedObject var card: Card
    
    var body: some View {
        VStack {
            Spacer()
            Button {
                container.interactor.system.PushActionView(.CreateRecord(budget, card))
            } label: {
                RoundedRectangle(cornerRadius: Setting.deviceCornerRadius)
                    .frame(height: 90)
                    .foregroundColor(.backgroundButton)
                    .shadow(radius: 5)
                    .overlay {
                        Label("button.record.create", systemImage: "plus.square.dashed")
                            .font(.system(size: 28, weight: .light))
                            .kerning(2)
                            .foregroundColor(card.color)
                            .padding(size*0.15)
                            .padding(.bottom)
                    }
            }
        }
        .ignoresSafeArea(.all)
    }
}

// MARK: - Property
extension AddRecordButtonLayer {
    var size: CGFloat {
        System.device.screen.width*0.2
    }
}

#if DEBUG
struct AddRecordButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.background
            AddRecordButtonLayer(budget: .preview, card: .preview)
                .inject(DIContainer.preview)
                .preferredColorScheme(.dark)
        }
    }
}
#endif
