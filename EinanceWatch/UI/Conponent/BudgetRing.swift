import SwiftUI
import Ditto

struct BudgetRing: View {
    @ObservedObject var budget: Budget
    @State private var category: FinanceCategory = .cost
    @State private var values: [CGFloat] = []
    @State var size: CGFloat = System.screen(.width, 0.8)
    @State var line: CGFloat = 10
    var body: some View {
        ZStack {
            ring()
            text()
        }
        .background(Color.transparent)
        .frame(width: size, height: size)
        .onTapGesture {
            withAnimation(.medium) {
                category = category != .balance ? .balance : .cost
            }
        }
    }
    
    @ViewBuilder
    private func text() -> some View {
        Text(category == .balance ? "label.balance" : "label.cost")
            .frame(width: size*0.8)
            .font(.system(size: size*0.2, weight: .light))
            .kerning(2)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
    }
    
    @ViewBuilder
    private func ring() -> some View {
        let dict = calculateDegree()
        ZStack {
            Circle()
                .stroke(Color.section, lineWidth: line)
            ForEach(budget.book.reversed()) { c in
                if !c.isForever {
                    Circle()
                        .trim(from: 0, to: dict[c.id] ?? 0)
                        .stroke(c.bColor, lineWidth: 10)
                }
            }
        }
        .rotationEffect(Angle(degrees: -90))
    }
}

fileprivate extension BudgetRing {
    private func calculateDegree() -> [Int64:CGFloat] {
        var dict: [Int64:CGFloat] = [:]
        var value: CGFloat = 0
        for card in budget.book {
            if !card.isForever {
                value += ratioFormula(card, budget.amount)
                dict[card.id] = value
            }
        }
        return dict
    }
    
    private func ratioFormula(_ c: Categoriable, _ amount: Decimal) -> CGFloat {
        if category == .balance {
                return (c.balance/amount).cgfloat
        }
        return (c.cost/amount).cgfloat
    }
}

#if DEBUG
struct BudgetRing_Previews: PreviewProvider {
    static var previews: some View {
        BudgetRing(budget: .preview)
    }
}
#endif
