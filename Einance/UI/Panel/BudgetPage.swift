import SwiftUI
import UIComponent

struct BudgetPage: View {
    @EnvironmentObject private var container: DIContainer
    @State private var aboveBudgetCategory: BudgetCategory = .Cost
    @State private var belowBudgetCategory: BudgetCategory = .Amount
    
    @ObservedObject var budget: Budget
    @Binding var current: Card
    
    var body: some View {
        VStack(spacing: 0) {
            Dashboard(budget: budget)
                .padding(.horizontal)
            
            TabView(selection: $current) {
                ForEach(budget.book) { card in
                    CardRect(budget: budget, card: card)
                        .padding()
                        .tag(card)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .frame(height: System.device.screen.height*0.36)
            
            if !current.dateDict.isEmpty {
                List {
                    ForEach(current.dateDict.keys.reversed(), id: \.self) { unixDay in
                        HStack {
                            Text(Date(unixDay).String("MM/dd EEEE", .init(identifier: Locale.preferredLanguages[0])))
                            Block(height: 1, color: .section)
                            Text("\(current.dateDict[unixDay]!.cost.description) $")
                        }
                        .animation(.none, value: current)
                        .foregroundColor(.gray)
                        .font(.caption)
                        ForEach(current.dateDict[unixDay]!.records, id: \.id) { record in
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
            
            Spacer()
        }
        .transition(.opacity)
        .animation(.quick, value: current)
        .onAppear {
            UIPageControl.appearance().currentPageIndicatorTintColor = .darkGray
            UIPageControl.appearance().pageIndicatorTintColor = .lightGray
            UIPageControl.appearance().tintColor = .lightGray
        }
    }
}

// MARK: - Function
extension BudgetPage {}

struct BudgetPage_Previews: PreviewProvider {
    static var previews: some View {
        BudgetPage(budget: .preview, current: .constant(.preview))
            .inject(DIContainer.preview)
            .preferredColorScheme(.dark)
    }
}
