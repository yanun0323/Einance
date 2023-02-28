import SwiftUI
import UIComponent

struct RecordRow: View {
    @EnvironmentObject private var container: DIContainer
    @State var record: Record
    @State var color: Color
    @State var isForever: Bool
    
    var body: some View {
        HStack {
            Block(width: 4, color: color)
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
                    withAnimation {
                        print("record deleted")
                    }
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                
                Button(role: .none) {
                    container.interactor.system.PushActionView(EditRecordPanel(record: record, isForever: isForever))
                } label: {
                    Label("Edit", systemImage: "square.and.pencil")
                }
            }
        }
    }
}

struct RecordRow_Previews: PreviewProvider {
    static var previews: some View {
        RecordRow(record: .preview, color: .green, isForever: false)
            .inject(DIContainer.preview)
            .previewLayout(.sizeThatFits)
    }
}
