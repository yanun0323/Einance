import SwiftUI
import UIComponent

struct SystemInteractor {
    private var appstate: AppState
    private var repo: Repository
    
    init(appstate: AppState, repo: Repository) {
        self.appstate = appstate
        self.repo = repo
    }
}

extension SystemInteractor {
    func PushRouterView(_ router: AppState.ViewRouter) {
        System.Async {
            appstate.routerViewPublisher.send(router)
        }
    }
    
    func ClearRouterView() {
        System.Async {
            appstate.routerViewPublisher.send(.Empty)
        }
    }
    
    func PushActionView(_ router: AppState.ActionRouter) {
        System.Async {
            appstate.actionViewPublisher.send(router)
            appstate.actionViewEmptyPublisher.send(false)
        }
    }
    
    func ClearActionView() {
        System.Async {
            appstate.actionViewPublisher.send(.Empty)
            appstate.actionViewEmptyPublisher.send(true)
        }
    }
    
    func DismissKeyboard() {
        withAnimation(.quick) {
            UIApplication.shared.DismissKeyboard()
        }
    }
    
    func PushPickerState(isOn: Bool) {
        System.Async {
            appstate.pickerPublisher.send(isOn)
        }
    }
    
    func TriggerMonthlyCheck() {
        System.Async {
            appstate.monthlyCheckPublisher.send(true)
        }
    }
}
