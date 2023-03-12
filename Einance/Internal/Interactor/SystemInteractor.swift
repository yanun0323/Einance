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
    func PushRouterView(_ content: RouterView) {
        System.Async {
            appstate.routerViewPublisher.send(content)
        }
    }
    
    func ClearRouterView() {
        System.Async {
            appstate.routerViewPublisher.send(nil)
        }
    }
    
    func PushActionView(_ content: ActionView) {
        System.Async {
            appstate.actionViewPublisher.send(content)
        }
    }
    
    func ClearActionView() {
        System.Async {
            appstate.actionViewPublisher.send(nil)
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
