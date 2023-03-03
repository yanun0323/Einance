import SwiftUI
import UIComponent

struct BudgetPage: View {
    @EnvironmentObject private var container: DIContainer
    @State private var aboveBudgetCategory: BudgetCategory = .Cost
    @State private var belowBudgetCategory: BudgetCategory = .Amount
    @State private var recordsExist: Bool = false
    @State var budget: Budget
    @Binding var current: Card
    
    var body: some View {
        VStack(spacing: 0) {
            Dashboard(budget: budget)
                .padding(.horizontal)
            
            TabView(selection: $current) {
                ForEach(budget.book) { card in
                    CardRect(card: card)
                        .padding()
                        .tag(card)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .frame(height: System.device.screen.height*0.36)
            
            if recordsExist {
                List {
                    ForEach(current.dateDict.keys.reversed(), id: \.self) { unixDay in
                        HStack {
                            Text(Date(unixDay).String("MM/dd EEEE", .init(identifier: Locale.preferredLanguages[0])))
                            Block(height: 1, color: .section)
                            Text("\(current.dateDict[unixDay]!.cost.description) $")
                        }
                        .foregroundColor(.gray)
                        .font(.caption)
                        ForEach(current.dateDict[unixDay]!.records, id: \.id) { record in
                            RecordRow(record: record, color: current.color, isForever: current.display == .forever)
                        }
                    }
                    .navigationBarHidden(true)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
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
#if DEBUG
            print("[DEBUG] Budget ID: \(budget.id), Card Count: \(budget.book.count)")
            print("[DEBUG] Current Card ID: \(current.id), Name: \(current.name), Color: \(current.color)")
#endif
        }
        .onReceive(container.appstate.updateBudgetIDPublisher) { id in
            withAnimation {
                if budget.id == id, let b = container.interactor.data.GetBudget(id) {
                    for c in b.book {
                        if c.id == current.id {
                            current = c
                            recordsExist = !c.dateDict.isEmpty
                            break
                        }
                    }
                    budget = b
                }
            }
        }
        .onChange(of: current) { value in
            withAnimation {
                recordsExist = !value.dateDict.isEmpty
            }
        }
    }
}

// MARK: - Function
extension BudgetPage {
}

struct BudgetPage_Previews: PreviewProvider {
    static var previews: some View {
        BudgetPage(budget: .preview, current: .constant(.preview3))
            .inject(DIContainer.preview)
            .preferredColorScheme(.dark)
    }
}
