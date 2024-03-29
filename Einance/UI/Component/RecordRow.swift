import SwiftUI
import UIComponent

struct RecordRow: View {
    @EnvironmentObject private var container: DIContainer
    @ObservedObject var budget: Budget
    @ObservedObject var card: Card
    @ObservedObject var record: Record
    
    var body: some View {
        HStack {
            if record.fixed {
                Image(systemName: "pin")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .rotationEffect(Angle(degrees: 45))
                    .foregroundColor(card.color)
                    .padding(.trailing, 10)
            } else {
                Block(width: 4, color: card.color)
                    .padding(.trailing, 10)
            }
            Text(record.memo)
                .foregroundColor(.primary50)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer()
            Text("\(record.cost.description) $")
        }
        .font(.system(size: 17, weight: .light, design: .rounded))
        .kerning(1)
        .padding(.horizontal)
        .monospacedDigit()
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            trailingSwapeAction()
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            leadingSwapeAction()
        }
    }
    
    @ViewBuilder
    private func trailingSwapeAction() -> some View {
        HStack {
            Button(role: .destructive) {
                withAnimation(.quick) {
                    container.interactor.data.DeleteRecord(budget, card, record)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
            
            Button(role: .none) {
                container.interactor.system.PushActionView(.EditRecord(budget, card, record))
            } label: {
                Label("Edit", systemImage: "square.and.pencil")
            }
        }
    }
    
    @ViewBuilder
    private func leadingSwapeAction() -> some View {
        if card.fixed {
            Button(role: .cancel) {
                withAnimation(.quick) {
                    let fixed = !record.fixed
                    container.interactor.data.UpdateRecord(budget, card, record, date: record.date, cost: record.cost, memo: record.memo, fixed: fixed)
                }
            } label: {
                Label("Fixed", systemImage: "pin")
                    .foregroundColor(card.color)
            }
        }
    }
}

#if DEBUG
struct RecordRow_Previews: PreviewProvider {
    static var previews: some View {
        RecordRow(budget: .preview, card: .preview, record: .preview)
            .inject(DIContainer.preview)
            .previewLayout(.sizeThatFits)
    }
}
#endif
