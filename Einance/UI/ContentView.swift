import SwiftUI
import UIComponent

struct ContentView: View {
    @EnvironmentObject private var container: DIContainer
    @State private var routerView: AnyView? = nil
    @State private var actionView: AnyView? = nil
    @State private var isKeyboardActive = false
    @State private var isPickerActive = false
    @State private var stopTheWorld = false
    @State private var isUpdating = false
    
    @StateObject private var budget: Budget
    @State private var current: Card = .empty
    @State private var timer: Timer?
    @State private var bookCount: Int = 0
    private let isPreview: Bool
    
    // TODO: move current budget and card here
    init(injector: DIContainer, preview: Budget? = nil, isPreview: Bool = false) {
        self.isPreview = isPreview
        if let b = preview {
            self._budget = .init(wrappedValue: b)
            return
        }
        
        self._budget = .init(wrappedValue: .empty)
    }
    
    var body: some View {
        ZStack {
            if budget.isZero && !isPreview {
                WelcomeView()
                    .disabled(stopTheWorld)
            } else {
                _BudgetExistView
                    .disabled(stopTheWorld)
            }
            
            if stopTheWorld {
                Color.background.opacity(0.9)
                    .ignoresSafeArea(.all)
                LoadingSymbol()
            }
        }
        .onReceive(container.appstate.routerViewPublisher) { output in
            withAnimation(.quick) {
                routerView = output
            }
        }
        .onReceive(container.appstate.actionViewPublisher) { output in
            withAnimation(.quick) {
                actionView = output
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
        .onReceive(container.appstate.budgetPublisher) { output in
            if isUpdating { return }
            guard let b = output else { return }
            withAnimation(.quick) {
                isUpdating = true
                defer { isUpdating = false }
                
                budget.Update(b)
                refreshCurrentCard()
                
                // make current card move to first
                bookCount = -1
                
                let expiredDate = budget.start.AddMonth(1)
                timer?.invalidate()
                timer = Timer.scheduledTimer(
                    withTimeInterval: 15, repeats: true,
                    block: { _ in
                        if container.interactor.setting.IsExpired(expiredDate) {
                            container.interactor.system.TriggerMonthlyCheck()
                        }
                    })
            }
        }
        .onReceive(container.appstate.monthlyCheckPublisher) { output in
            print("Monthly Publish Received")
            container.interactor.data.UpdateMonthlyBudget(budget)
        }
        .onReceive(container.appstate.stopTheWorldPublisher) { output in
            if stopTheWorld == output { return }
            withAnimation(.quick) {
                stopTheWorld = output
            }
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
}

// MARK: - View Block
extension ContentView {
    var _BudgetExistView: some View {
        ZStack {
            HomeView(budget: budget, current: $current)
                .ignoresSafeArea(.keyboard)
                .disabled(actionView != nil)
            ZStack {
                if routerView != nil {
                    routerView
                }
                
                if actionView != nil {
                    Rectangle()
                        .foregroundColor(.black.opacity(0.5))
                        .animation(.default, value: actionView.isNil)
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
                        actionView!
                        Spacer()
                    }
                    .animation(.default, value: actionView.isNil)
                    .transition(.opacity)
                    .ignoresSafeArea(.keyboard)
                }
            }
        }
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
        ContentView(injector: .preview, preview: .preview, isPreview: true)
            .inject(DIContainer.preview)
        ContentView(injector: .preview, preview: .preview)
            .inject(DIContainer.preview)
    }
}
