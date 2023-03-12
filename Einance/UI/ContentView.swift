import SwiftUI
import UIComponent

struct ContentView: View {
    @EnvironmentObject private var container: DIContainer
    @State private var viewRouter: AppState.ViewRouter = .Empty
    @State private var actionRouter: AppState.ActionRouter = .Empty
    @State private var isActionViewEmpty: Bool = true
    @State private var isKeyboardActive = false
    @State private var isPickerActive = false
    @State private var isUpdating = false
    
    @StateObject private var budget: Budget = .empty
    @State private var current: Card = .empty
    @State private var timer: Timer?
    @State private var bookCount: Int = 0
    
    var body: some View {
        VStack {
            if budget.isZero {
                WelcomeView()
            } else {
                _BudgetExistView
            }
        }
        .backgroundColor(.background)
        .onReceive(container.appstate.routerViewPublisher) { output in
            withAnimation(.quick) {
                viewRouter = output
            }
        }
        .onReceive(container.appstate.actionViewPublisher) { output in
            withAnimation(.quick) {
                actionRouter = output
            }
        }
        .onReceive(container.appstate.keyboardPublisher) { output in
            withAnimation(.quick) {
                isKeyboardActive = output
            }
        }
        .onReceive(container.appstate.pickerPublisher) { output in
            withAnimation(.quick) {
                isPickerActive = output
            }
        }
        .onSmoothRecive(.quick, container.appstate.actionViewEmptyPublisher) { isActionViewEmpty = $0 }
        .onReceive(container.appstate.budgetPublisher) { output in
            if isUpdating { return }
            guard let b = output else { return }
            withAnimation(.quick) {
                isUpdating = true
                defer { isUpdating = false }
                
                budget.Update(b)
                refreshCurrentCard()
                
                // make current card move to first
                bookCount = b.book.count
                
                timer?.invalidate()
                let start = budget.startAt
                timer = Timer.scheduledTimer(
                    withTimeInterval: 15, repeats: true,
                    block: { t in
                        if container.interactor.setting.IsExpired(start) {
                            container.interactor.system.TriggerMonthlyCheck()
                        }
                    })
            }
        }
        .onReceive(container.appstate.monthlyCheckPublisher) { output in
            print("Monthly Publish Received")
            container.interactor.data.UpdateMonthlyBudget(budget)
        }
        .onAppear {
            container.interactor.data.PublishCurrentBudget()
        }
        .onChange(of: budget.book.count) { _ in
            print("L: \(bookCount), R: \(budget.book.count)")
            withAnimation(.quick) {
                refreshCurrentCard()
            }
        }
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
        case let .Statistic(budget, card):
            StatisticView(budget: budget, card: card)
        case let .Debug(budget):
            DebugView(budget: budget)
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
}

// MARK: - View Block
extension ContentView {
    var _BudgetExistView: some View {
        ZStack {
            HomeView(budget: budget, current: current, selected: $current)
                .disabled(!isActionViewEmpty)
            ZStack {
                routerView()
                if !isActionViewEmpty {
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
                        .ignoresSafeArea(.all)
                    VStack {
                        actionView()
                        Spacer(minLength: 0)
                    }
                    .animation(.default, value: isActionViewEmpty)
                    .transition(.opacity)
                    .ignoresSafeArea(.all, edges: .bottom)
                }
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

// MARK: - Property
extension ContentView {
    var hasCards: Bool {
        budget.book.count != 0
    }
    
    func refreshCurrentCard() {
        defer { bookCount = budget.book.count }
        if !hasCards {
            current = .empty
            return
        }
        current = bookCount < budget.book.count ? budget.book.last! : budget.book.first!
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .inject(DIContainer.preview)
        ContentView()
            .inject(DIContainer.preview)
    }
}
