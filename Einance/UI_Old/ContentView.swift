import SwiftUI
import Ditto

struct ContentView: View {
    @Environment(\.injected) private var container: DIContainer
    @State private var viewRouter: ViewRouter? = nil
    @State private var actionRouter: ActionRouter? = nil
    @State private var isRouterViewEmpty: Bool = true
    @State private var isActionViewEmpty: Bool = true
    @State private var showRouterSheet: Bool = false
    @State private var showActionSheet: Bool = false
    @State private var isKeyboardActive = false
    @State private var isPickerActive = false
    @State private var isUpdating = false
    
    @StateObject private var budget: Budget = .blank()
    @State private var current: Card = .blank()
    @State private var expiredTimer: Timer?
    @State private var bookCount: Int = 0
    @State private var isInit: Bool = true
    
    @State private var cleanTagTimer: Timer?
    
    var body: some View {
        ZStack {
            if isInit {
                LoadingSymbol()
            } else {
                if budget.isBlank {
                    WelcomeView()
                } else {
                    budgetExistView()
                        .barSheet(isPresented: $showActionSheet) {
                            container.interactor.system.ClearActionView()
                        } content: {
                            actionView()
                        }
                        .barSheet(isPresented: $showRouterSheet) {
                            container.interactor.system.ClearRouterView()
                        } content: {
                            routerView()
                        }
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
        }
        .onReceived(container.appstate.actionViewPublisher) {
            actionRouter = $0
        }
        .onReceived(container.appstate.monthlyCheckPublisher) { _ = container.interactor.data.UpdateMonthlyBudget(budget) }
        .onChanged(of: budget.book.count) { refreshCurrentCard() }
        .onChanged(of: isActionViewEmpty) { showActionSheet = !$0 }
        .onChanged(of: isRouterViewEmpty) { showRouterSheet = !$0 }
        .onAppeared { handleOnAppear() }
        .animation(.quick, value: isActionViewEmpty)
    }
    
    @ViewBuilder
    private func routerView() -> some View {
        switch viewRouter {
            case nil:
                EmptyView()
            case let .Setting(di, budget, card):
                SettingView(injector: di, budget: budget, current: card)
            case let .BookOrder(budget):
                BookOrderView(budget: budget)
            case let .Statistic(budget):
                StatisticView(budget: budget)
            case let .Debug(budget):
                DebugView(budget: budget)
            case .Analysis:
                AnalysisView()
        }
    }
    
    @ViewBuilder
    private func actionView() -> some View {
        switch actionRouter {
            case nil:
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
//            ZStack {
//                routerView()

//                if !isActionViewEmpty {
//                    coverViewLayer()
//                        .ignoresSafeArea(.all)
//                    actionViewLayer()
//                }
//            }
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
            current = .blank()
            return
        }
        current = bookCount < budget.book.count ? budget.book.last! : budget.book.first!
    }
    
    func handleOnAppear() {
        container.interactor.data.PublishCurrentBudgetFromDB()
        cleanTagTimer = .scheduledTimer(withTimeInterval: .day, repeats: true) { _ in
            container.interactor.data.DeleteExpiredTags()
        }
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
            expiredTimer = .scheduledTimer(
                withTimeInterval: 15, repeats: true) { _ in
                    if container.interactor.setting.IsExpired(start) {
                        container.interactor.system.TriggerMonthlyCheck()
                    }
                }
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
