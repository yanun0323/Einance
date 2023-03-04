import SwiftUI
import UIComponent

struct BudgetPage: View {
    @EnvironmentObject private var container: DIContainer
    @State private var aboveBudgetCategory: BudgetCategory = .Cost
    @State private var belowBudgetCategory: BudgetCategory = .Amount
    @State private var recordsExist: Bool = false
    
    @ObservedObject var current: Current
    
    init(current cc: Current) {
        self._current = .init(wrappedValue: cc)
        UIPageControl.appearance().currentPageIndicatorTintColor = .darkGray
        UIPageControl.appearance().pageIndicatorTintColor = .lightGray
        UIPageControl.appearance().tintColor = .lightGray
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Dashboard(current: current)
                .padding(.horizontal)
            
            TabView(selection: $current.card) {
                ForEach(current.budget.book) { card in
                    CardRect(current: current, card: card)
                        .padding()
                        .tag(card)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .frame(height: System.device.screen.height*0.36)
            
            if !current.card.dateDict.isEmpty {
                List {
                    ForEach(current.card.dateDict.keys.reversed(), id: \.self) { unixDay in
                        HStack {
                            Text(Date(unixDay).String("MM/dd EEEE", .init(identifier: Locale.preferredLanguages[0])))
                            Block(height: 1, color: .section)
                            Text("\(current.dateDict[unixDay]!.cost.description) $")
                        }
                        .animation(.none, value: current)
                        .foregroundColor(.gray)
                        .font(.caption)
                        ForEach(current.card.dateDict[unixDay]!.records, id: \.id) { record in
                            RecordRow(current: current, record: record)
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
    }
}

// MARK: - Function
extension BudgetPage {}

struct BudgetPage_Previews: PreviewProvider {
    static var previews: some View {
        BudgetPage(current: .preview)
            .inject(DIContainer.preview)
            .preferredColorScheme(.dark)
    }
}
