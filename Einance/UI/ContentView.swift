import SwiftUI
import UIComponent

struct ContentView: View {
    @EnvironmentObject private var container: DIContainer
    @State private var routerView: AnyView? = nil
    @State private var actionView: AnyView? = nil
    @State private var isKeyboardActive = false
    @State private var isPickerActive = false
    @State private var stopTheWorld = false
    
    @StateObject private var budget: Budget
    @State private var current: Card = .empty
    
    
    // TODO: move current budget and card here
    init(injector: DIContainer, preview: Budget? = nil) {
        if let b = preview {
            self._budget = .init(wrappedValue: b)
            return
        }
        
        self._budget = .init(wrappedValue: .empty)
    }
    
    var body: some View {
        ZStack {
            if budget.isZero {
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
            withAnimation(.quick) {
                if let b = output {
                    budget.Update(b)
                }
            }
        }
        .onReceive(container.appstate.stopTheWorldPublisher) { output in
            withAnimation(.quick) {
                if stopTheWorld == output { return }
                stopTheWorld = output
            }
        }
        .onAppear {
            container.interactor.data.PublishCurrentBudget()
        }
        .onChange(of: budget.book.count) { count in
            withAnimation(.quick) {
                if hasCards {
                    current = budget.book.last!
                    return
                }
                
                current = .empty
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
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(injector: .preview)
            .inject(DIContainer.preview)
            .preferredColorScheme(.dark)
        ContentView(injector: .preview)
            .inject(DIContainer.preview)
    }
}
