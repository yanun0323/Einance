import SwiftUI
import Ditto

struct AddRecordButtonLayer: View {
    @Environment(\.injected) private var container: DIContainer
    
    @ObservedObject var budget: Budget
    @ObservedObject var card: Card
    
    var body: some View {
        VStack {
            Spacer()
            Button {
                container.interactor.system.PushActionView(.CreateRecord(budget, card))
            } label: {
                HStack {
                    Label("button.record.create", systemImage: "plus.square.dashed")
                        .font(.system(size: 28, weight: .light))
                        .kerning(2)
                        .foregroundColor(card.bColor)
                        .padding(size*0.15)
                        .padding(.bottom)
                }
                .clippedShadow(height: 90, y: -10)
            }
            .frame(height: 90)
        }
        .ignoresSafeArea(.all)
    }
}

// MARK: - Property
extension AddRecordButtonLayer {
    var size: CGFloat {
        System.screen.width*0.2
    }
}

#if DEBUG
struct AddRecordButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.background
            AddRecordButtonLayer(budget: .preview, card: .preview)
                .inject(DIContainer.preview)
                .preferredColorScheme(.light)
        }
    }
}
#endif
