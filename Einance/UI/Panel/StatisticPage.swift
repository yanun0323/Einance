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
    
    
    @ObservedObject var budget: Budget
    
    init(budget: Budget) {
        self._budget = .init(wrappedValue: budget)
        self.width = System.device.screen.width/(buttonCount+1)
        self.amountSums = []
        self.costSums = []
        self.balanceSums = []
        
        var amount: Decimal = 0
        var cost: Decimal = 0
        var balance: Decimal = 0
        
        budget.book.forEach { card in
            if !card.isForever {
                amount += card.amount
                cost += card.cost
                balance += card.balance
            }
            amountSums.append(amount)
            costSums.append(cost)
            balanceSums.append(balance)
        }
    }
    
    var body: some View {
        VStack {
            infoBlock()
                .padding()
            pieChartView()
            Spacer()
        }
        .backgroundColor(.background)
        .onAppear {
            UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.label
            UIPageControl.appearance().pageIndicatorTintColor = .lightGray
            UIPageControl.appearance().tintColor = .lightGray
        }
    }
    
    @ViewBuilder
    private func viewCategoryRowButtons() -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: height*0.5)
                .foregroundColor(.background)
                .frame(width: width, height: height)
                .offset(x: CGFloat(selectedType)*width)
                .shadow(color: .black.opacity(0.2), radius: 3)
            HStack(spacing: 0) {
                rowButton(0, "chart.pie.fill")
                rowButton(1, "chart.bar.xaxis")
            }
        }
        .padding(3)
        .background {
            RoundedRectangle(cornerRadius: height*0.6)
                .foregroundColor(.section)
        }
    }
    
    @ViewBuilder
    private func infoBlock() -> some View {
        HStack(spacing: 30) {
            VStack(alignment: .leading)  {
                Text("statistic.date_start.label")
                Text("statistic.date_end.label")
                    .padding(.bottom, 5)
                Text("label.amount")
                Text("label.cost")
                Text("label.balance")
            }
            .font(.system(.title3, weight: .medium))
            VStack(alignment: .trailing) {
                Text(budget.startAt.String("yyyy.MM.dd"))
                Text(budget.startAt.String("yyyy.MM.dd"))
                    .padding(.bottom, 5)
                Text(budget.amount.description)
                Text(budget.cost.description)
                Text(budget.balance.description)
            }
            .font(.system(.title3))
            .monospacedDigit()
        }
    }
    
    @ViewBuilder
    private func rowButton(_ index: Int, _ image: String) -> some View {
        ButtonCustom(width: width, height: height) {
            withAnimation(.quick) {
                selectedType = index
            }
        } content: {
            Image(systemName: image)
                .font(.title3)
                .foregroundColor(selectedType == index ? .primary.opacity(0.9) : .section)
        }
    }
    
    @ViewBuilder
    private func pieChartView() -> some View {
        TabView {
            pie(for: .amount)
            pie(for: .cost)
            pie(for: .balance)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
    }
    
    @ViewBuilder
    private func pie(for t: DataType) -> some View {
        if let data = t.data(a: amountSums, c: costSums, b: balanceSums),
           let sum = data.last {
            let lineWidth: CGFloat = System.device.screen.width/7
            let radius: CGFloat = System.device.screen.width/3
            ZStack(alignment: .center) {
                VStack {
                    Text(t.label())
                        .font(.system(.title2, weight: .heavy))
                        .padding(.bottom, 5)
                    if let index = selectedIndex {
                        let c = budget.book[index]
                        Text(c.name)
                            .lineLimit(1)
                        Text(t.value(c).description)
                    } else {
                        Text("-")
                        Text("-")
                    }
                }
                .frame(width: radius)
                
                ForEach(budget.book.indices, id: \.self) { i in
                    let c = budget.book[i]
                    let value = t.value(c)
                    if value != 0 && !c.isForever {
                        pieSlice(for: i, before: data[i], sum: sum, value: value, radius: radius, line: lineWidth)
                    }
                }
            }
            .frame(width: System.device.screen.width, height: System.device.screen.width)
        }
    }
    
    @ViewBuilder
    private func pieSlice(for index: Int, before: Decimal, sum: Decimal, value: Decimal, radius: CGFloat, line: CGFloat) -> some View {
        let f = (before - value) / sum
        let t = before / sum
        let width = selectedIndex == index ? line + 15 : line
        Circle()
            .trim(from: f.ToCGFloat(), to: t.ToCGFloat() - 0.003)
            .stroke(budget.book[index].color, lineWidth: width)
            .frame(width: radius*2, height: radius*2)
            .rotationEffect(.degrees(-90))
            .padding(line)
            .onTapGesture {
                withAnimation(.quick) {
                    if selectedIndex != index {
                        selectedIndex = index
                    } else {
                        selectedIndex = nil
                    }
                }
            }
        
        let p = (value/sum)*100
        Text("\(Int(p.ToDouble()))%")
            .font(.system(p <= 5 ? .caption : .title3, weight: p <= 0.05 ? .regular : .heavy))
            .foregroundColor(.white)
            .offset(textOffset2(before: before, sum: sum, value: value, radius: radius))
            .zIndex(1)
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
        StatisticPage(budget: .preview)
            .inject(DIContainer.preview)
            .preferredColorScheme(.dark)
    }
}
#endif

private enum DataType {
    case amount, cost, balance
    
    func data(a: [Decimal], c: [Decimal], b: [Decimal]) -> [Decimal]? {
        switch self {
            case .amount:
                return a
            case .cost:
                return c
            case .balance:
                return b
        }
    }
    
    func value(_ from: Card) -> Decimal {
        switch self {
            case .amount:
                return from.amount
            case .cost:
                return from.cost
            case .balance:
                return from.balance
        }
    }
    
    func label() -> LocalizedStringKey {
        switch self {
            case .amount:
                return "label.amount"
            case .cost:
                return "label.cost"
            case .balance:
                return "label.balance"
        }
    }
}
