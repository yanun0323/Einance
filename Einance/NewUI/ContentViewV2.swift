import Ditto
import SwiftUI

struct ContentViewV2: View {
    @Environment(\.injected) private var container: DIContainer
    @State private var actionRouter: ActionRouter? = nil
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
                        .barSheet(isPresented: Binding(get: { actionRouter != nil }, set: { _ in }))
                    {
                        container.interactor.system.ClearActionView()
                    } content: {
                        actionView(actionRouter)
                    }
                }
            }
        }
        .onReceived(container.appstate.pickerPublisher) { isPickerActive = $0 }
        .onReceived(container.appstate.budgetPublisher) { handleBudgetChange($0) }
        .onReceived(container.appstate.keyboardPublisher) { isKeyboardActive = $0 }
        .onReceived(container.appstate.actionViewPublisher) { actionRouter = $0 }
        .onReceived(container.appstate.monthlyCheckPublisher) {
            _ = container.interactor.data.UpdateMonthlyBudget(budget)
        }
        .onChanged(of: budget.book.count) { refreshCurrentCard() }
        .onAppeared { handleOnAppear() }
    }

    @ViewBuilder
    private func routerView(_ router: ViewRouter?) -> some View {
        switch router {
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
    private func actionView(_ router: ActionRouter?) -> some View {
        switch router {
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
            HomeViewV2(budget: budget, current: current, selected: $current)
        }
    }
}

// MARK: - Function
extension ContentViewV2 {

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
        isInit = false
        if output?.updatedAt == budget.updatedAt { return }
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
                withTimeInterval: 15, repeats: true
            ) { _ in
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
