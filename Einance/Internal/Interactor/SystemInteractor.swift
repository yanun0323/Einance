import SwiftUI
import Ditto

struct SystemInteractor {
    private var appstate: AppState
    private var repo: Repository
    
    init(appstate: AppState, repo: Repository) {
        self.appstate = appstate
        self.repo = repo
    }
}

extension SystemInteractor {
    func PushContentViewRouter(_ showV2: Bool) {
        System.async {
            appstate.contentViewV2Publisher.send(showV2)
        }
    }
    
    func PushRouterView(_ router: ViewRouter?) {
        System.async {
            appstate.routerViewPublisher.send(router)
        }
    }
    
    func ClearRouterView() {
        System.async {
            appstate.routerViewPublisher.send(nil)
        }
    }
    
    func PushActionView(_ router: ActionRouter?) {
        System.async {
            appstate.actionViewPublisher.send(router)
        }
    }
    
    func ClearActionView() {
        System.async {
            appstate.actionViewPublisher.send(nil)
        }
    }
    
    #if os(iOS)
    func DismissKeyboard() {
        withAnimation(.quick) {
            UIApplication.shared.dismissKeyboard()
        }
    }
    #endif
    
    func PushPickerState(isOn: Bool) {
        System.async {
            appstate.pickerPublisher.send(isOn)
        }
    }
    
    func TriggerMonthlyCheck() {
        System.async {
            appstate.monthlyCheckPublisher.send(true)
        }
    }
}
