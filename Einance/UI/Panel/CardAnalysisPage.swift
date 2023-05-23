import SwiftUI
import UIComponent
import OrderedCollections

struct CardAnalysisPage: View {
    @Environment(\.locale) private var locale: Locale
    typealias Dict = OrderedDictionary<Date, Card.RecordSet>
    @EnvironmentObject private var container: DIContainer
    @GestureState private var scaleOffset: CGSize = .zero
    @State private var scrollScale: CGFloat = 1.0
    @State private var dayDict: Dict = [:]
    @State private var monthDict: Dict = [:]
    @State private var dict: Dict = [:]
    @State private var debugInfo = ""
    
    @State private var selectedData: Data? = nil
    var card: Card
    
    @State private var chartType: ChartType = .month
    @State private var selected: Date? = nil
    @State private var maxDayCost: Decimal = 0
    @State private var maxMonthCost: Decimal = 0
    @State private var dayRatio: CGFloat = 0
    @State private var monthRatio: CGFloat = 0
    @State private var chartSheetValue: [Decimal] = []
    @State private var gap: CGFloat = 50
    
    private let scrollOuter: CGFloat = System.device.screen.width - 40
    private let outer: CGFloat = System.device.screen.width - 40
    private let inner: CGFloat = System.device.screen.width - 50 - 50/* unitHeight */
    private let defaultGap: CGFloat = 50
    
    #if DEBUG
    var preview = false
    #endif
    
    var body: some View {
        VStack {
            typeSelector()
            chart()
                .animation(.none, value: chartType)
            Text(debugInfo)
//            dataList()
            Spacer()
        }
        .onChanged(of: chartType) { handleChartTypeChanged() }
        .onAppeared {
            var cards = container.interactor.data.ListCards(by: card.chainID)
            #if DEBUG
            if preview {
                cards = container.interactor.data.ListCards(by: .init(uuidString: "189F3B34-F609-4FD0-AC5A-F5F3F3E36109")!)
            }
            #endif
            var recordsCount = 0
            for c in cards {
                let records = container.interactor.data.ListRecords(by: c.id)
                recordsCount += records.count
                for r in records {
                    guard let dayKey = Date(from: r.date.String("yyyyMMdd"), "yyyyMMdd") else { continue }
                    guard let monthKey = Date(from: r.date.String("yyyyMM"), "yyyyMM") else { continue }
                    insertIntoDayDict(key: dayKey, r)
                    insertIntoMonthDict(key: monthKey, r)
                    
                    if let d = dayDict[dayKey]?.cost, d > maxDayCost {
                        maxDayCost = d
                    }
                    
                    if let m = monthDict[monthKey]?.cost, m > maxMonthCost {
                        maxMonthCost = m
                    }
                }
            }
            
            dayDict.sort()
            monthDict.sort()
            
            dayRatio = inner/(maxDayCost.ToCGFloat())
            monthRatio = inner/(maxMonthCost.ToCGFloat())
            
            handleChartTypeChanged()
        }
    }
    
    @ViewBuilder
    private func typeSelector() -> some View {
        let w: CGFloat = 100
        let h: CGFloat = 40
        HStack(spacing: 0) {
            typeSelectorButton(set: .month, "card.display.month", w, h)
            typeSelectorButton(set: .day, "card.display.day", w, h)
        }
        .backgroundColor(.section)
        .background {
            HStack {
                if chartType == .day {
                    Block(height: h)
                }
                RoundedRectangle(cornerRadius: h/2)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 2.5)
                    .foregroundColor(card.color)
                    .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
                if chartType == .month {
                    Block(height: h)
                }
            }
        }
        .cornerRadius(h/2)
    }
    
    @ViewBuilder
    private func typeSelectorButton(set t: ChartType, _ s: LocalizedStringKey, _ w: CGFloat, _ h: CGFloat) -> some View {
        ButtonCustom(width: w, height: h) {
            withAnimation(.quick) {
                if chartType != t {
                    chartType = t
                }
            }
        } content: {
            Text(s)
                .foregroundColor(chartType == t ? card.fontColor : .section)
        }
    }
    
    @ViewBuilder
    private func chart() -> some View {
        let fixed = inner/2
        let dotSize: CGFloat = gap/6
        let ratio = ratio()
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                ZStack {
                    chartLine(dotSize)
                    HStack(spacing: 0) {
                        ForEach(dict.keys, id: \.self) { date in
                            let set = dict[date]!
                            ZStack {
                                ZStack {
                                    Text(set.cost.description)
                                        .font(.caption2)
                                        .foregroundColor(.primary75)
                                        .offset(y: -15)
                                    Circle()
                                        .frame(width: dotSize)
                                        .foregroundColor(card.color)
                                }
                                .offset(y: fixed - (set.cost.ToCGFloat()*ratio))
                                
                                Text(date.String(chartType == .day ? "MM/dd" : "yy.MM"))
                                    .font(.caption2)
                                    .foregroundColor(.primary25)
                                    .kerning(0)
                                    .offset(y: fixed + 10)
                                    .monospacedDigit()
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(1)
                                Block(width: 1, height: inner, color: .section)
                            }
                            .frame(width: gap, height: inner)
                            .backgroundColor(selected == date ? .section : .transparent)
                            .id(date)
                            .onTapGesture {
                                selected = date
                            }
                        }
                    }
                }
                .scaleEffect(x: scrollScale)
            }
            .onAppeared { handleScroll(proxy) }
            .onChanged(of: dict.count) { handleScroll(proxy) }
            .onChanged(of: selected) { handleScroll(proxy, set: $0) }
        }
        .frame(width: scrollOuter, height: outer, alignment: .trailing)
        .gesture(
            MagnificationGesture(minimumScaleDelta: 5)
                .onChanged { val in
                    let result = gap + (gap * val - gap) * 0.5
                    debugInfo = "\(val)\n\(result)"
                    
                    if result < defaultGap && result > 10 {
                        gap = result
                    }
                }
        )
        .background {
            chartSheet()
        }
    }
    
    @ViewBuilder
    private func chartLine(_ dotSize: CGFloat) -> some View {
        let lineWidth: CGFloat = 2
        let yFixed = outer - (outer-inner)/2
        let xFixed = gap/2
        let ratio = ratio()
        let w = CGFloat(dict.keys.count) * gap

        var count = dict.keys.count - 1
        var first = true
        Path() { p in
            for d in dict.keys.reversed() {
                let set = dict[d]!
                let point = CGPoint(x: xFixed + CGFloat(count)*gap, y: yFixed - set.cost.ToCGFloat()*ratio)
                if first {
                    p.move(to: point)
                    first = false
                }
                p.addLine(to: point)
                count -= 1
            }
        }
        .stroke(card.color, lineWidth: lineWidth)
        .frame(width: w)
    }
    
    @ViewBuilder
    private func chartSheet() -> some View {
        let fixed = inner/2
        let ratio = ratio()
        ZStack {
            ForEach(chartSheetValue, id: \.self) { v in
                let g = v.ToCGFloat()*ratio
                Block(height: 1, color: .section)
                    .offset(y: fixed - g)
                
                HStack {
                    Spacer()
                    Text(v.description)
                        .font(.system(size: 10))
                        .foregroundColor(.section)
                        .offset(y: fixed - g + 5)
                }
            }
            
            Block(height: 1, color: .section)
                .offset(y: fixed)
            
            Block(height: 1, color: .section)
                .offset(y: -fixed)
        }
    }
    
    @ViewBuilder
    private func dataList() -> some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                ForEach(dict.keys.reversed(), id: \.self) { date in
                    LazyVStack(spacing: 0) {
                        HStack {
                            Text(date.String(chartType == .day ? "yyyy.MM.dd" : "yyyy.MM", locale))
                                .kerning(1)
                            Block(height: 1, color: .section)
                                .padding(.horizontal)
                            Text("\(dict[date]!.cost.description) $")
                        }
                        .foregroundColor(.gray)
                        .font(.caption)
                        .id(date)
                        .padding(.bottom, 10)
                        
                        ForEach(dict[date]!.records, id: \.id) { record in
                            HStack {
                                Block(width: 4, color: card.color)
                                    .padding(.trailing, 10)
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
                            .frame(height: 25)
                            .padding(5)
                            .monospacedDigit()
                        }
                    }
                    .padding(10)
                    .padding(.bottom, 5)
                    .backgroundColor(selected == date ? .section : .transparent)
                    .cornerRadius(7)
                    .onTapGesture {
                        selected = date
                    }
                    .padding(.horizontal, 30)
                }
            }
            .onAppeared { handleScroll(proxy) }
            .onChanged(of: dict.count) { handleScroll(proxy) }
            .onChanged(of: selected) { handleScroll(proxy, set: $0) }
        }
    }
}

extension CardAnalysisPage {
    
    private func insertIntoDayDict(key: Date, _ r: Record) {
        if dayDict[key].isNil {
            dayDict[key] = Card.RecordSet()
        }
        
        dayDict[key]?.cost += r.cost
        dayDict[key]?.records.append(r)
    }
    
    private func insertIntoMonthDict(key: Date, _ r: Record) {
        if monthDict[key].isNil {
            monthDict[key] = Card.RecordSet()
        }
        
        monthDict[key]?.cost += r.cost
        monthDict[key]?.records.append(r)
    }
    
    private func calculateChardSheetValue(max: Decimal) {
        var ten: Decimal = 10
        var fif: Decimal = 5
        while max/(ten*10) > 1 {
            ten *= 10
            fif *= 10
        }
        // 123 100:1 50:2
        // 235 100:2 50:4
        // 881 100:8 50:16
        
        let volumn = max/ten > 5 ? ten : fif
        
        var result: [Decimal] = []
        
        for i in 1...20 {
            let value = Decimal(i)*volumn
            if value >= max {
                break
            }
            result.append(value)
        }
        
        chartSheetValue = result
    }
    
    
    private func setDict() -> Dict {
        return chartType == .month ? monthDict : dayDict
    }
    
    private func maxCost() -> Decimal {
        return chartType == .month ? maxMonthCost : maxDayCost
    }
    
    private func ratio() -> CGFloat {
        return chartType == .month ? monthRatio : dayRatio
    }
    
    private func setGap() -> CGFloat {
        let g = outer/CGFloat(dict.count)
        return g > defaultGap ? g : defaultGap
    }
    
    private func handleChartTypeChanged() {
        selected = nil
        dict = setDict()
        gap = setGap()
        calculateChardSheetValue(max: maxCost())
    }
    
    private func handleScroll(_ proxy: ScrollViewProxy, set target: Date? = nil) {
        proxy.scrollTo(target ?? dict.keys.last ?? .now)
    }
}

#if DEBUG
struct CardAnalysisPage_Previews: PreviewProvider {
    static var previews: some View {
        CardAnalysisPage(card: .preview, preview: true)
            .inject(DIContainer.preview)
            .environment(\.locale, .US)
    }
}
#endif

extension CardAnalysisPage {
    enum ChartType {
        case day, month
    }
}
