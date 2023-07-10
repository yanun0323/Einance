import SwiftUI
import Ditto
import OrderedCollections

struct AnalysisView: View {
    @Environment(\.injected) private var container: DIContainer
    @State var selected: Budget? = nil
    @State var budgetDict: OrderedDictionary<String, [Budget]> = [:]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                chartBlock()
                statisticBlock()
            }
            .background(Color.background)
        }
        .navigationTitle("view.header.analysis")
        .onAppeared {
            let budgets = container.interactor.data.ListBudgets()
            selected = budgets.first
            budgets.forEach { b in
                let year = b.startAt.string("yyyy")
                if budgetDict[year] == nil {
                    budgetDict[year] = []
                }
                budgetDict[year]?.append(b)
            }
        }
    }
    
    @ViewBuilder
    private func chartBlock() -> some View {
        let dotSize: CGFloat = 7
        let dotBlock: CGFloat = 40
        let height: CGFloat = 100 // System.screen.width/4
        let gap: CGFloat = 50
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: gap) {
                Spacer()
                ForEach(budgetDict.keys.elements, id: \.self) { year in
                    let count = CGFloat(budgetDict[year]!.count)
                    let width: CGFloat = count * (dotBlock + gap)
                    ZStack {
                        VStack {
                            Spacer()
                            Block(width: width - 2*(dotBlock+dotSize), height: 1, color: .primary25)
                                .padding(.bottom, dotSize/2 + 1)
                        }
                        VStack {
                            HStack {
                                Text(year)
                                    .font(.title)
                                    .foregroundColor(.primary25)
                                    .padding(.top, 10)
                                    .offset(x: -gap)
                                Spacer()
                            }
                            Spacer()
                        }
                        HStack(spacing: gap) {
                            ForEach(budgetDict[year]!) { b in
                                VStack {
                                    Spacer()
                                    dotUnit(b, size: dotSize, block: dotBlock)
                                }
                            }
                        }
                        .frame(width: width)
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: height)
            .padding(.bottom, 50)
        }
        .clippedShadow(height: 150)
    }
    
    @ViewBuilder
    private func dotUnit(_ b: Budget, size: CGFloat, block: CGFloat) -> some View {
        VStack(spacing: 2) {
            Text(b.startAt.string("MM.dd"))
                .font(selected?.id == b.id ? .system(size: 13) : .caption2)
            Block(width: 1, height: selected?.id == b.id ? block*0.8 : 0 , color: .primary25)
            ZStack {
                Circle()
                    .foregroundColor(selected?.id == b.id ? .primary : .background)
                    .frame(width: size, height: size)
                Circle()
                    .stroke(lineWidth: 2)
                    .foregroundColor(selected?.id == b.id ? .primary : .primary25)
                    .frame(width: size, height: size)
            }
            .padding(.bottom, 1)
        }
        .frame(width: block, alignment: .bottom)
        .padding(.top)
        .backgroundColor(.transparent)
        .onTapGesture {
            withAnimation(.quick) {
                selected = b
            }
        }
    }
    
    @ViewBuilder
    private func statisticBlock() -> some View {
        if selected != nil {
            StatisticPage(injecter: container, budget: selected!)
                .animation(.none, value: selected)
        }
    }
    
}

#if DEBUG
struct AnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        AnalysisView()
            .inject(DIContainer.preview)
            .environment(\.locale, .us)
            .preferredColorScheme(.light)
    }
}
#endif
