import SwiftUI
import UIComponent

struct ContentView: View {
    @EnvironmentObject private var container: DIContainer
    @State private var routerView: AnyView? = nil
    @State private var actionView: AnyView? = nil
    @State private var isKeyboardActive = false
    @State private var isPickerActive = false
    
    @StateObject private var current: Current = .empty
    
    // TODO: move current budget and card here
    init(injector: DIContainer, preview: Budget? = nil) {
        if let b = preview {
            self.current.budget = b
            return
        }
        
        if let b = injector.interactor.data.GetCurrentBudget() {
            self.current.budget = b
            return
        }
    }
    
    var body: some View {
        ZStack {
            if current.budget.isZero {
                WelcomeView()
            } else {
                _BudgetExistView
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
        .onReceive(container.appstate.updateBudgetIDPublisher) { output in
            withAnimation(.quick) {
                if let b = container.interactor.data.GetCurrentBudget() {
                    current.budget = b
                }
            }
        }
        .onAppear {
            withAnimation(.quick) {
                if let _ = current.budget.book.first(where: { $0.id == current.card.id }) {
                    return
                }
                
                if hasCards {
                    current.card = current.budget.book.first!
                    return
                }
            }
        }
        .onChange(of: current.budget.book.count) { count in
            withAnimation(.quick) {
                if let _ = current.budget.book.first(where: { $0.id == current.card.id }) {
                    return
                }
                
                if hasCards {
                    current.card = current.budget.book.first!
                    return
                }
                
                current.card = .empty
            }
        }
    }
}

// MARK: - View Block
extension ContentView {
    var _BudgetExistView: some View {
        ZStack {
            HomeView(current: current)
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
        current.budget.book.count != 0
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
