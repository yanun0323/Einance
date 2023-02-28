import SwiftUI
import UIComponent

struct Dashboard: View {
    @State var budget: Budget
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("label.balance")
                Spacer()
                Text("label.cost")
            }
            BarBlock
            HStack {
                Text(budget.balance.description)
                Spacer()
                Text(budget.cost.description)
            }
        }
        .font(.system(size: 20, weight: .regular, design: .rounded))
        .kerning(5)
        .monospacedDigit()
    }
}

// MARK: - View Block
extension Dashboard {
    var BarBlock: some View {
        GeometryReader { bounds in
            HStack(spacing: 0) {
                Spacer()
                ForEach(budget.book) { card in
                    Rectangle()
                        .frame(width: (card.cost/budget.amount).ToCGFloat()*bounds.size.width)
                        .foregroundColor(card.color)
                }
            }
        }
        .frame(height: 15)
        .background(Color.section.opacity(0.5))
        .cornerRadius(5, antialiased: true)
    }
}

struct Dashboard_Previews: PreviewProvider {
    static var previews: some View {
        Dashboard(budget: .preview)
    }
}
