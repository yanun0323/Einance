import SwiftUI
import UIComponent

struct BudgetPage: View {
    @EnvironmentObject private var container: DIContainer
    @Environment(\.locale) private var locale: Locale
    @State private var aboveBudgetCategory: BudgetCategory = .Cost
    @State private var belowBudgetCategory: BudgetCategory = .Amount
    
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
            UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.label
            UIPageControl.appearance().pageIndicatorTintColor = .lightGray
            UIPageControl.appearance().tintColor = .lightGray
        }
    }
    
    @ViewBuilder
    private func dashboardView() -> some View {
        Dashboard(budget: budget, current: current)
            .padding(.horizontal)
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
                        .offset(y: System.device.screen.height*0.01)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .frame(height: System.device.screen.height*0.34, alignment: .top)
        }
        .ignoresSafeArea(.keyboard)
        .scrollDisabled(true)
    }
    
    @ViewBuilder
    private func recordListView() -> some View {
        if current.hasRecord {
            List {
                fixedRecordList()
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
    private func fixedRecordList() -> some View {
        if current.hasFixRecord {
            HStack {
                Text("view.record.row.title.fixed")
                Block(height: 1, color: .section)
                Text("\(current.pinnedCost.description) $")
            }
            .foregroundColor(.gray)
            .font(.caption)
            .navigationBarHidden(true)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            
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
                Text(date.String("MM/dd EEEE", locale))
                Block(height: 1, color: .section)
                Text("\(current.dateDict[date]!.cost.description) $")
            }
            .foregroundColor(.gray)
            .font(.caption)
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
            .environment(\.locale, .US)
    }
}
#endif
