import SwiftUI
import UIComponent

struct RecordRow: View {
    @EnvironmentObject private var container: DIContainer
    @ObservedObject var budget: Budget
    @ObservedObject var card: Card
    @ObservedObject var record: Record
    
    var body: some View {
        HStack {
            Block(width: 4, color: card.color)
                .padding(.trailing, 10)
            Text(record.memo)
                .foregroundColor(.primary50)
            Spacer()
            Text("\(record.cost.description) $")
        }
        .font(.system(size: 17, weight: .light, design: .rounded))
        .kerning(1)
        .padding(.horizontal)
        .monospacedDigit()
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            HStack {
                Button(role: .destructive) {
                    withAnimation(.quick) {
                        container.interactor.data.DeleteRecord(budget, card, record)
                        print("record deleted")
                    }
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                
                Button(role: .none) {
                    container.interactor.system.PushActionView(EditRecordPanel(budget: budget, card: card, record: record))
                } label: {
                    Label("Edit", systemImage: "square.and.pencil")
                }
            }
        }
    }
}

struct RecordRow_Previews: PreviewProvider {
    static var previews: some View {
        RecordRow(budget: .preview, card: .preview, record: .preview)
            .inject(DIContainer.preview)
            .previewLayout(.sizeThatFits)
    }
}
