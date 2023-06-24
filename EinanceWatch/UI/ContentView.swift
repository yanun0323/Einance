import Ditto
import SwiftUI
import WatchConnectivity

struct ContentView: View {
    @Environment(\.injected) private var container
    @StateObject private var budget: Budget = .blank()
    @State private var message: String = "-"

    var body: some View {
        VStack(spacing: 10) {
            NavigationStack {
                TabView {
                    addRecordTab()
                        .navigationTitle("panel.record.create.target_card.label")
                        .navigationBarTitleDisplayMode(.inline)
                    BudgetRing(budget: budget, line: 5)
                }
                .tabViewStyle(.automatic)
            }
        }
        .font(.system(size: 14))
        .onReceive(container.appstate.currentBudget) { budget.Update($0) }
        .onReceive(container.appstate.message) { message = $0 }
        .onAppear { handleAppeared() }
    }
    
    @ViewBuilder
    private func addRecordTab() -> some View {
        ScrollView(.vertical, showsIndicators: true) {
            LazyVStack(spacing: 10) {
                ForEach(budget.book) { card in
                    NavigationLink {
                        CardView(card: card)
                    } label: {
                        Text(card.name)
                            .font(.system(size: 18, weight: .medium))
                            .kerning(1)
                            .lineLimit(1)
                            .padding(.horizontal, 5)
                            .frame(width: 150, height: 40)
                            .backgroundLinearGradient(card.bgColor)
                            .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    @ViewBuilder
    private func addRecordLink() -> some View {
        
    }

    #if DEBUG
    @ViewBuilder
    private func button() -> some View {
        let size: CGFloat = System.screen(.width, 0.8)
        Button(width: size, height: size * 0.3, colors: [.blue, .glue], radius: 25) {
            container.interactor.watch.sendMessage(Date.now.string("yyyy-MM-dd hh:mm:ss"))
        } content: {
            Image(systemName: "icloud.and.arrow.up.fill")
                .foregroundColor(.white)
                .font(.system(size: 30))
        }
    }
    #endif
}

fileprivate extension ContentView {
    private func handleAppeared() {
        guard let b = container.interactor.watch.getStoredBudget() else {
            budget.Update(.blank())
            return
        }
        budget.Update(b)
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .inject(.preview)
    }
}
#endif
