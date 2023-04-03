import SwiftUI
import UIComponent
import Charts

struct StatisticView: View {
    @EnvironmentObject private var container: DIContainer
    @State private var selectedType: Int = 0
    @State private var height: CGFloat = 30
    @State private var width: CGFloat
    private let buttonCount: CGFloat = 2
    private let sliceOffset: Double = -.pi / 2
    private let amounts: [Decimal]
    private let costs: [Decimal]
    
    @ObservedObject var budget: Budget
    
    init(budget: Budget) {
        self._budget = .init(wrappedValue: budget)
        self.width = System.device.screen.width/(buttonCount+1)
        self.amounts = budget.book.map({ $0.amount })
        self.costs = budget.book.map({ $0.isForever ? 0 : $0.cost })
    }
    
    var body: some View {
        VStack {
            ViewHeader(title: "view.header.statistic")
            viewCategoryRowButtons()
                .transition(.opacity)
            infoBlock()
                .padding()
            chartRouter()
            Spacer()
        }
        .modifyRouterBackground()
        .transition(.scale(scale: 0.95, anchor: .top).combined(with: .opacity))
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
        HStack {
            VStack(alignment: .leading)  {
                Text("label.amount")
                Text("label.cost")
                Text("label.balance")
            }
            VStack(alignment: .trailing) {
                Text(budget.amount.description)
                Text(budget.cost.description)
                Text(budget.balance.description)
            }
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
    private func chartRouter() -> some View {
        switch selectedType {
            case 1:
                rectChartView()
            default:
                pieChartView()
        }
    }
    
    @ViewBuilder
    private func pieChartView() -> some View {
        TabView {
            pie(for: .amount)
            pie(for: .cost)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
    }
    
    @ViewBuilder
    private func pie(for t: DataType) -> some View {
        let data = t.data(a: amounts, c: costs)
        let sum = data.reduce(0.0, +)
        let lineWidth: CGFloat = System.device.screen.width/7
        let radius: CGFloat = System.device.screen.width/3.2
        ZStack(alignment: .center) {
            ForEach(budget.book.indices, id: \.self) { i in
                if data[i] != 0 {
                    pieSlice(for: i, data: data, sum: sum, line: lineWidth)
                    VStack {
                        Text("\(Int(((data[i]/sum)*100).ToDouble()))%")
                            .font(.system(.title3, weight: .heavy))
                            .foregroundColor(.white)
                    }
                    .offset(textOffset(for: i, data: data, radius: radius))
                    .zIndex(1)
                }
            }
        }
    }
    
    @ViewBuilder
    private func pieSlice(for index: Int, data: [Decimal], sum: Decimal, line: CGFloat) -> some View {
        let f = data[..<index].reduce(0.0, +) / sum
        let t = data[..<(index+1)].reduce(0.0, +) / sum
        Circle()
            .trim(from: f.ToCGFloat(), to: t.ToCGFloat() - 0.003)
            .stroke(budget.book[index].color, lineWidth: line)
            .rotationEffect(.degrees(-90))
            .padding(line)
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

extension StatisticView {
    private func textOffset(for index: Int, data: [Decimal], radius: CGFloat) -> CGSize {
        let dataRatio = (2 * data[..<index].reduce(0, +) + data[index]) / (2 * data.reduce(0, +))
        let angle = CGFloat(sliceOffset + 2 * .pi * dataRatio.ToDouble())
        return CGSize(width: radius * cos(angle), height: radius * sin(angle))
    }
    
}

#if DEBUG
struct StatisticView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticView(budget: .preview)
            .inject(DIContainer.preview)
            .preferredColorScheme(.light)
        StatisticView(budget: .preview)
            .inject(DIContainer.preview)
            .preferredColorScheme(.dark)
    }
}
#endif

private enum DataType {
    case amount, cost
    
    func data(a: [Decimal], c: [Decimal]) -> [Decimal] {
        if self == .amount {
            return a
        }
        return c
    }
    
    func double(_ from: Card) -> Decimal {
        if self == .amount {
            return from.amount
        }
        return from.cost
    }
}

private struct PieSlice: Shape {
    let startAngle: Double
    let endAngle: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = min(rect.width, rect.height) / 2
        let alpha = CGFloat(startAngle)
        
        let center = CGPoint(
            x: rect.midX,
            y: rect.midY
        )
        
        path.move(to: center)
        
        path.addLine(
            to: CGPoint(
                x: center.x + cos(alpha) * radius,
                y: center.y + sin(alpha) * radius
            )
        )
        
        path.addArc(
            center: center,
            radius: radius,
            startAngle: Angle(radians: startAngle),
            endAngle: Angle(radians: endAngle),
            clockwise: false
        )
        
        path.closeSubpath()
        
        return path
    }
}
