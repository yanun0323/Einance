import SwiftUI
import UIComponent

struct ContentViewV2: View {
    @EnvironmentObject private var container: DIContainer
    @State private var viewRouter: AppState.ViewRouter = .Empty
    @State private var actionRouter: AppState.ActionRouter = .Empty
    @State private var isRouterViewEmpty: Bool = true
    @State private var isActionViewEmpty: Bool = true
    @State private var showRouterSheet: Bool = false
    @State private var showActionSheet: Bool = false
    @State private var isKeyboardActive = false
    @State private var isPickerActive = false
    @State private var isUpdating = false
    
    @StateObject private var budget: Budget = .empty
    @State private var current: Card = .empty
    @State private var expiredTimer: Timer?
    @State private var bookCount: Int = 0
    @State private var isInit: Bool = true
    
    @State private var cleanTagTimer: Timer?
    
    var body: some View {
        ZStack {
            if isInit {
                LoadingSymbol()
            } else {
                if budget.isZero {
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
            isRouterViewEmpty = $0.isEmpty
        }
        .onReceived(container.appstate.actionViewPublisher) {
            actionRouter = $0
            isActionViewEmpty = $0.isEmpty
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
            case .Analysis:
                AnalysisView()
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
            HomeViewV2(budget: budget, current: current, selected: $current)
                .disabled(!isActionViewEmpty)
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
extension ContentViewV2 {
    
    func refreshCurrentCard() {
        defer { bookCount = budget.book.count }
        if !budget.HasCard() {
            current = .empty
            return
        }
        current = bookCount < budget.book.count ? budget.book.last! : budget.book.first!
    }
    
    func handleOnAppear() {
        container.interactor.data.PublishCurrentBudget()
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
struct ContentViewV2_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewV2()
            .inject(DIContainer.preview)
        ContentViewV2()
            .inject(DIContainer.preview)
    }
}
#endif

