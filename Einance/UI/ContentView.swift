import SwiftUI
import UIComponent

struct ContentView: View {
    @EnvironmentObject private var container: DIContainer
    @State private var viewRouter: AppState.ViewRouter = .Empty
    @State private var actionRouter: AppState.ActionRouter = .Empty
    @State private var isRouterViewEmpty: Bool = true
    @State private var isActionViewEmpty: Bool = true
    @State private var isKeyboardActive = false
    @State private var isPickerActive = false
    @State private var isUpdating = false
    
    @StateObject private var budget: Budget = .empty
    @State private var current: Card = .empty
    @State private var expiredTimer: Timer?
    @State private var bookCount: Int = 0
    @State private var isInit: Bool = true
    
    var body: some View {
        ZStack {
            if isInit {
                LoadingSymbol()
            } else {
                if budget.isZero {
                    WelcomeView()
                } else {
                    budgetExistView()
                }
            }
        }
        .animation(.quick, value: isActionViewEmpty)
        .animation(.quick, value: isRouterViewEmpty)
        .onReceived(container.appstate.pickerPublisher) { isPickerActive = $0 }
        .onReceived(container.appstate.budgetPublisher) {
            handleBudgetChange($0)
            isInit = false
        }
        .onReceived(container.appstate.keyboardPublisher) { isKeyboardActive = $0 }
        .onReceived(container.appstate.routerViewPublisher) {
            viewRouter = $0
            isRouterViewEmpty = $0.isEmpty
        }
        .onReceived(container.appstate.actionViewPublisher) {
            actionRouter = $0
            isActionViewEmpty = $0.isEmpty
        }
        .onReceived(container.appstate.monthlyCheckPublisher) { container.interactor.data.UpdateMonthlyBudget(budget) }
        .onChanged(of: budget.book.count) { refreshCurrentCard() }
        .onAppear { container.interactor.data.PublishCurrentBudget() }
        .animation(.quick, value: isActionViewEmpty)
    }
    
    @ViewBuilder
    private func routerView() -> some View {
        switch viewRouter {
            case .Empty:
                EmptyView()
            case let .Setting(di, budget, card):
                SettingView(injector: di, budget: budget, current: card)
            case let .BookOrder(budget):
                BookOrderView(budget: budget)
            case let .Statistic(budget):
                StatisticView(budget: budget)
            case let .Debug(budget):
                DebugView(budget: budget)
            case .History:
                HistoryView()
        }
    }
    
    @ViewBuilder
    private func actionView() -> some View {
        switch actionRouter {
            case .Empty:
                EmptyView()
            case let .CreateCard(budget):
                CreateCardPanel(budget: budget)
            case let .EditCard(budget, card):
                EditCardPanel(budget: budget, card: card)
            case let .CreateRecord(budget, card):
                CreateRecordPanel(budget: budget, card: card)
            case let .EditRecord(budget, card, record):
                EditRecordPanel(budget: budget, card: card, record: record)
        }
    }
    
    @ViewBuilder
    private func budgetExistView() -> some View {
        ZStack {
            HomeView(budget: budget, current: current, selected: $current)
                .disabled(!isActionViewEmpty)
            ZStack {
                routerView()
                if !isActionViewEmpty {
                    coverViewLayer()
                        .ignoresSafeArea(.all)
                    actionViewLayer()
                }
            }
        }
    }
    
    @ViewBuilder
    private func coverViewLayer() -> some View {
        Rectangle()
            .foregroundColor(.black.opacity(0.5))
            .animation(.default, value: isActionViewEmpty)
            .onTapGesture {
                if isKeyboardActive || isPickerActive {
                    container.interactor.system.PushPickerState(isOn: false)
                    container.interactor.system.DismissKeyboard()
                    return
                }
                container.interactor.system.ClearActionView()
            }
            .transition(.opacity)
    }
    
    @ViewBuilder
    private func actionViewLayer() -> some View {
        VStack {
            actionView()
        }
        .transition(.opacity)
    }
}

// MARK: - Function
extension ContentView {
    
    func refreshCurrentCard() {
        defer { bookCount = budget.book.count }
        if !budget.HasCard() {
            current = .empty
            return
        }
        current = bookCount < budget.book.count ? budget.book.last! : budget.book.first!
    }
    
    func handleBudgetChange(_ output: Budget?) {
        if isUpdating { return }
        guard let b = output else { return }
        withAnimation(.quick) {
            isUpdating = true
            defer { isUpdating = false }
            
            budget.Update(b)
            
            // make current card move to first
            bookCount = b.book.count
            refreshCurrentCard()
            
            expiredTimer?.invalidate()
            let start = budget.startAt
            expiredTimer = Timer.scheduledTimer(
                withTimeInterval: 5, repeats: true,
                block: { _ in
                    if container.interactor.setting.IsExpired(start) {
                        container.interactor.system.TriggerMonthlyCheck()
                    }
                })
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .inject(DIContainer.preview)
        ContentView()
            .inject(DIContainer.preview)
    }
}
#endif

