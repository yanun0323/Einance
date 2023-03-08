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
    func PushRouterView<V: View>(_ content: V) {
        System.Async {
            appstate.routerViewPublisher.send(AnyView(content))
        }
    }
    
    func ClearRouterView() {
        System.Async {
            appstate.routerViewPublisher.send(nil)
        }
    }
    
    func PushActionView<V: View>(_ content: V) {
        System.Async {
            appstate.actionViewPublisher.send(AnyView(content))
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
    
    func StopTheWorld() {
        appstate.stopTheWorldPublisher.send(true)
    }
    
    func RunTheWorld() {
        appstate.stopTheWorldPublisher.send(false)
    }
}
