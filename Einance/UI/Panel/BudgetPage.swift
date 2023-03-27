import SwiftUI
import UIComponent

struct BudgetPage: View {
    @EnvironmentObject private var container: DIContainer
    @State private var aboveBudgetCategory: BudgetCategory = .Cost
    @State private var belowBudgetCategory: BudgetCategory = .Amount
    
    @ObservedObject var budget: Budget
    @ObservedObject var current: Card
    @Binding var selected: Card
    
    var body: some View {
        VStack(spacing: 0) {
            Dashboard(budget: budget, current: current)
                .padding(.horizontal)
                .onTapGesture {
                    container.interactor.system.PushRouterView(.Statistic(budget, current))
                }
            
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
                .frame(height: System.device.screen.height*0.335)
            }
            .ignoresSafeArea(.keyboard)
            .scrollDisabled(true)
            
            if !current.dateDict.isEmpty || !current.fixedArray.isEmpty {
                List {
                    if !current.fixedArray.isEmpty {
                        HStack {
                            Text("view.record.row.title.fixed")
                            Block(height: 1, color: .section)
                            Text("\(current.fixedCost.description) $")
                        }
                        .foregroundColor(.gray)
                        .font(.caption)
                        .navigationBarHidden(true)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    
                    ForEach(current.fixedArray) { record in
                        RecordRow(budget: budget, card: current, record: record)
                    }
                    .navigationBarHidden(true)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    
                    ForEach(current.dateDict.keys.reversed(), id: \.self) { date in
                        HStack {
                            Text(date.String("MM/dd EEEE", .init(identifier: Locale.preferredLanguages[0])))
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
                .animation(.none, value: current)
                .scrollContentBackground(.hidden)
                .environment(\.defaultMinListRowHeight, 0)
                .listStyle(.plain)
                .backgroundColor(.clear)
                .monospacedDigit()
                .padding(.horizontal)
                
            }
            
            Block(height: 65)
            Spacer(minLength: 0)
        }
        .transition(.opacity)
        .animation(.quick, value: current)
        .onAppear {
            UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.label
            UIPageControl.appearance().pageIndicatorTintColor = .lightGray
            UIPageControl.appearance().tintColor = .lightGray
        }
    }
}

#if DEBUG
struct BudgetPage_Previews: PreviewProvider {
    static var previews: some View {
        BudgetPage(budget: .preview, current: .preview, selected: .constant(.preview))
            .inject(DIContainer.preview)
            .preferredColorScheme(.light)
    }
}
#endif
