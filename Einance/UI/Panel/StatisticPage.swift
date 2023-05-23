import SwiftUI
import UIComponent
import Charts

struct StatisticPage: View {
    @EnvironmentObject private var container: DIContainer
    @State private var selectedType: Int = 0
    @State private var height: CGFloat = 30
    @State private var width: CGFloat
    @State private var selectedIndex: Int? = nil
    private let buttonCount: CGFloat = 2
    private let sliceOffset: Double = -.pi / 2
    private var amountSums: [Decimal]
    private var costSums: [Decimal]
    private var balanceSums: [Decimal]
    private var showableData: Int
    
    
    @ObservedObject var budget: Budget
    @State var chainedCards: [Card]
    
    init(injecter: DIContainer, budget: Budget) {
        self._budget = .init(wrappedValue: budget)
        self.width = System.device.screen.width/(buttonCount+1)
        self.amountSums = []
        self.costSums = []
        self.balanceSums = []
        self.showableData = 0
//        self.chainedCards = injecter.interactor.data.ListChainableCards(by: budget)
        self.chainedCards = injecter.interactor.data.ListChainableCards()
        
        var amount: Decimal = 0
        var cost: Decimal = 0
        var balance: Decimal = 0
        
        budget.book.forEach { card in
            if !card.isForever {
                amount += card.amount
                cost += card.cost
                balance += card.balance
                showableData += 1
            }
            amountSums.append(amount)
            costSums.append(cost)
            balanceSums.append(balance)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 30) {
                    overviewBlock()
                    pieBlock(for: .amount)
                    pieBlock(for: .cost)
                    cardBlock()
                    Block(height: 1)
                }
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private func overviewBlock() -> some View {
        let dataSpan = budget.archiveAt.isNil ? "\(budget.startAt.String("yyyy.MM.dd")) ~ " : "\(budget.startAt.String("yyyy.MM.dd")) ~ \(budget.archiveAt!.String("yyyy.MM.dd"))"
        statisticSection("statistic.overview.lable", dataSpan) {
            VStack(spacing: 25) {
                financeInfo(.amount)
                financeInfo(.cost)
                financeInfo(.balance)
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private func financeInfo(_ t: FinanceCategory) -> some View {
        VStack(spacing: 0) {
            Text(t.label())
                .font(.system(.headline, weight: .regular))
                .foregroundColor(.primary25)
            Text("$ \(t.value(budget).description)  ")
                .font(.system(.title, weight: .medium))
                .monospacedDigit()
        }
    }
    
    @ViewBuilder
    private func pieBlock(for t: FinanceCategory) -> some View {
        statisticSection(t.label(), "$\(t.value(budget).description)") {
            piePanel(for: t)
        }
    }
    
    @ViewBuilder
    private func piePanel(for t: FinanceCategory, radiusRatio: CGFloat = 0.08, lineWidthRatio: CGFloat = 0.04) -> some View {
        if let data = t.data(a: amountSums, c: costSums, b: balanceSums),
           let sum = data.last {
            let lineWidth: CGFloat = System.device.screen.width * lineWidthRatio
            let radius: CGFloat = System.device.screen.width * radiusRatio
            
            HStack {
                Spacer()
                ZStack {
                    ForEach(budget.book.indices, id: \.self) { i in
                        let c = budget.book[i]
                        let value = t.value(c)
                        if value != 0 && !c.isForever {
                            pieSlice(for: i, before: data[i], sum: sum, value: value, radius: radius, line: lineWidth, showText: false)
                        }
                    }
                }
                Spacer()
                let blockSize: CGFloat = System.device.screen.width * 0.02
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(budget.book.indices, id: \.self) { i in
                        let c = budget.book[i]
                        let p = t.value(c)
                        if p != 0 && !c.isForever {
                            HStack {
                                Block(width: blockSize, height: blockSize, color: c.color)
                                Text(c.name)
                                    .foregroundColor(.primary25)
                                    .frame(width: (System.device.screen.width - radius) * 0.23, alignment: .leading)
                                Text("\(Int(((p/sum)*100).ToDouble()))%")
                                    .frame(width: (System.device.screen.width - radius) * 0.16, alignment: .leading)
                            }
                            .font(.system(.body, weight: .bold))
                            .lineLimit(1)
                            .monospacedDigit()
                            .padding(.vertical, 5)
                            .padding(.leading)
                            .backgroundColor(selectedIndex == i ? .primary25.opacity(0.8) : .transparent)
                            .cornerRadius(5)
                            .onTapGesture {
                                withAnimation(.quick) {
                                    if selectedIndex != i {
                                        selectedIndex = i
                                    } else {
                                        selectedIndex = nil
                                    }
                                }
                            }
                        }
                    }
                }
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private func pieSlice(for index: Int, before: Decimal, sum: Decimal, value: Decimal, radius: CGFloat, line: CGFloat, showText: Bool = false) -> some View {
        let f = (before - value) / sum
        let t = before / sum
        let width = selectedIndex == index ? line * 1.5 : line
        let gap: CGFloat = 0.003
        let only = (value/sum) == 1
        
        pieCircle(from: f.ToCGFloat(), to: t.ToCGFloat() - gap, color: budget.book[index].color, width: width, radius: radius, padding: line, only: only)
        
        if showText {
            let p = (value/sum)*100
            Text("\(Int(p.ToDouble()))%")
                .font(.system(p <= 5 ? .caption : .title3, weight: p <= 0.05 ? .regular : .heavy))
                .foregroundColor(.white)
                .offset(textOffset2(before: before, sum: sum, value: value, radius: radius))
                .zIndex(1)
        }
    }
    
    @ViewBuilder
    private func pieCircle(from f: CGFloat, to t: CGFloat, color: Color, width: CGFloat, radius: CGFloat, padding line: CGFloat, only: Bool) -> some View {
        if only {
            Circle()
                .stroke(color, lineWidth: width)
                .frame(width: radius*2, height: radius*2)
                .padding(line)
        } else {
            Circle()
                .trim(from: f, to: t)
                .stroke(color, lineWidth: width)
                .frame(width: radius*2, height: radius*2)
                .rotationEffect(.degrees(-90))
                .padding(line)
        }
    }
    
    @ViewBuilder
    private func rectChartView() -> some View {
        Chart {
            ForEach(budget.book) { card in
                BarMark(
                    x: .value("Card", card.name),
                    y: .value("Cost", card.cost),
                    stacking: .unstacked
                )
                .foregroundStyle(card.color)
                .annotation {
                    Text(card.cost.description)
                        .foregroundColor(card.color)
                        .padding(.bottom, 5)
                        .fontWeight(.bold)
                }
            }
            ForEach(budget.book) { card in
                BarMark(
                    x: .value("Card", card.name),
                    y: .value("Amount", card.amount),
                    stacking: .standard
                )
                .foregroundStyle(card.color.opacity(0.4))
                .annotation {
                    if !card.amount.isZero {
                        Text(card.amount.description)
                            .foregroundColor(card.color.opacity(0.4))
                            .padding(.bottom, 5)
                            .fontWeight(.bold)
                    }
                }
            }
            
        }
        .chartXAxis(.visible)
        .chartYAxis(.visible)
    }
    
    @ViewBuilder
    private func cardBlock() -> some View {
        statisticSection("statistic.card_analysis.label") {
            VStack {
                ForEach(chainedCards) { c in
                    NavigationLink {
                        CardAnalysisPage(card: c)
                    } label: {
                        cardRowLabel(card: c)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func cardRowLabel(card c: Card, _ blockSize: CGFloat = 10) -> some View {
        HStack {
            Spacer()
            Text(c.name)
                .foregroundColor(.primary25)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(c.color)
        }
        .font(.title3)
        .padding(.vertical, 5)
        .padding(.horizontal)
        .cornerRadius(7)
    }
    
    @ViewBuilder
    private func statisticSection(_ key: LocalizedStringKey, _ subkey: String = "", @ViewBuilder content: () -> some View) -> some View {
        VStack {
            VStack(spacing: 5) {
                HStack(alignment: .bottom) {
                    Text(key)
                        .font(.system(.title3, weight: .medium))
                    Text(subkey)
                        .font(.system(.caption))
                        .foregroundColor(.primary25)
                        .kerning(1)
                    Spacer()
                }
            }
            HStack {
                Spacer()
                content()
                Spacer()
            }
        }
        .monospacedDigit()
    }
    
    
}

extension StatisticPage {
    private func textOffset(for index: Int, data: [Decimal], radius: CGFloat) -> CGSize {
        let dataRatio = (2 * data[..<index].reduce(0, +) + data[index]) / (2 * data.reduce(0, +))
        let angle = CGFloat(sliceOffset + 2 * .pi * dataRatio.ToDouble())
        return CGSize(width: radius * cos(angle), height: radius * sin(angle))
    }
    
    private func textOffset2(before: Decimal, sum: Decimal, value: Decimal ,radius: CGFloat) -> CGSize {
        let dataRatio = (2 * (before - value) + value) / (2 * sum)
        let angle = CGFloat(sliceOffset + 2 * .pi * dataRatio.ToDouble())
        return CGSize(width: radius * cos(angle), height: radius * sin(angle))
    }
}

#if DEBUG
struct StatisticPage_Previews: PreviewProvider {
    static var previews: some View {
        StatisticPage(injecter: DIContainer.preview, budget: .preview)
            .inject(DIContainer.preview)
            .preferredColorScheme(.light)
            .environment(\.locale, .US)
    }
}
#endif
