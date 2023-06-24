import Ditto
import SwiftUI

struct DetailRow: View {
    @GestureState private var dragOffset: CGFloat = .zero
    @State private var endOffset: CGFloat = .zero
    @ObservedObject var r: Record
    var body: some View {
        HStack {
            Text(r.memo)
                .kerning(1)
                .opacity(0.3)
            Spacer()
            Text("\(r.cost.description) $")
                .font(.system(size: 22))
                .opacity(0.3)
            if dragOffset < .zero || endOffset < .zero {
                HStack {
                    Button(width: 60, height: 30, color: .red) {

                    } content: {
                        Image(systemName: "trash")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .fontWeight(.regular)
        .padding(.leading)
        .gesture(
            DragGesture()
                .updating($dragOffset) { v, state, _ in
                    System.async {
                        withAnimation {
                            endOffset = v.translation.width
                        }
                    }
                }
                .onEnded { v in
                    withAnimation {
                        endOffset = v.translation.width
                    }
                }
        )
    }
}

struct DetailRow_Previews: PreviewProvider {
    static var previews: some View {
        DetailRow(r: .preview)
    }
}
