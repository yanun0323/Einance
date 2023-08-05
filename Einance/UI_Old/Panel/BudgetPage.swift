import SwiftUI
import Ditto

struct BudgetPage: View {
    @Environment(\.injected) private var container: DIContainer
    @Environment(\.locale) private var locale: Locale
    @State private var aboveBudgetCategory: FinanceCategory = .cost
    @State private var belowBudgetCategory: FinanceCategory = .amount
    
    @ObservedObject var budget: Budget
    @ObservedObject var current: Card
    @Binding var selected: Card
    
    var body: some View {
        VStack(spacing: 0) {
            dashboardView()
            cardTableView()
            recordListView()
            Block(height: 90)
        }
        .ignoresSafeArea(.keyboard)
        .transition(.opacity)
        .animation(.quick, value: current)
        .onAppear {
//            UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.label
//            UIPageControl.appearance().pageIndicatorTintColor = .lightGray
//            UIPageControl.appearance().tintColor = .lightGray
        }
    }
    
    @ViewBuilder
    private func dashboardView() -> some View {
        Dashboard(budget: budget, current: current)
            .padding()
            .onTapGesture {
                container.interactor.system.PushRouterView(.Statistic(budget))
            }
    }
    
    @ViewBuilder
    private func cardTableView() -> some View {
        ScrollView {
            TabView(selection: $selected) {
                ForEach(budget.book) { card in
                    CardRect(budget: budget, card: card)
                        .padding(.horizontal)
                        .tag(card)
                        .offset(y: System.screen.height*0.01)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .frame(height: System.screen.height*0.34, alignment: .top)
        }
        .ignoresSafeArea(.keyboard)
        .scrollDisabled(true)
    }
    
    @ViewBuilder
    private func recordListView() -> some View {
        if current.hasRecord {
            List {
                pinnedRecordList()
                dateRecordList()
            }
            .animation(.none, value: current)
            .scrollContentBackground(.hidden)
            .environment(\.defaultMinListRowHeight, 0)
            .listStyle(.plain)
            .backgroundColor(.clear)
            .monospacedDigit()
            .padding(.horizontal)
            
        }
    }
    
    @ViewBuilder
    private func pinnedRecordList() -> some View {
        if current.hasFixRecord {
            HStack {
                Text("view.record.row.title.pinned")
                Block(height: 1, color: .section)
                    .padding(.horizontal)
                Text("\(current.pinnedCost.description) $")
            }
            .foregroundColor(.gray)
            .font(.caption)
            .navigationBarHidden(true)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .padding(.top, 10)
            
            ForEach(current.pinnedArray) { record in
                RecordRow(budget: budget, card: current, record: record)
            }
            .navigationBarHidden(true)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
    }
    
    @ViewBuilder
    private func dateRecordList() -> some View {
        ForEach(current.dateDict.keys.reversed(), id: \.self) { date in
            HStack {
                Text(date.string("MM/dd EEEE", locale))
                Block(height: 1, color: .section)
                    .padding(.horizontal)
                Text("\(current.dateDict[date]!.cost.description) $")
            }
            .foregroundColor(.gray)
            .font(.caption)
            .padding(.top, 10)
            ForEach(current.dateDict[date]!.records, id: \.id) { record in
                RecordRow(budget: budget, card: current, record: record)
            }
        }
        .navigationBarHidden(true)
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
    
}

#if DEBUG
struct BudgetPage_Previews: PreviewProvider {
    static var previews: some View {
        BudgetPage(budget: .preview, current: .preview, selected: .constant(.preview))
            .inject(DIContainer.preview)
            .preferredColorScheme(.light)
            .backgroundColor(.background)
            .environment(\.locale, .us)
    }
}
#endif
