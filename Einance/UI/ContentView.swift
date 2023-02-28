import SwiftUI
import UIComponent

struct ContentView: View {
    @EnvironmentObject private var container: DIContainer
    @State private var routerView: AnyView? = nil
    @State private var actionView: AnyView? = nil
    @State private var isKeyboardActive = false
    @State private var isPickerActive = false
    
    var body: some View {
        ZStack {
            HomeView(injector: container)
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
        .onReceive(container.appstate.routerViewPublisher) { output in
            withAnimation {
                routerView = output
            }
        }
        .onReceive(container.appstate.actionViewPublisher) { output in
            withAnimation {
                actionView = output
            }
        }
        .onReceive(container.appstate.keyboardPublisher) { output in
            withAnimation {
                isKeyboardActive = output
            }
        }
        .onReceive(container.appstate.pickerPublisher) { output in
            withAnimation {
                isPickerActive = output
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .inject(DIContainer.preview)
            .preferredColorScheme(.dark)
        ContentView()
            .inject(DIContainer.preview)
    }
}
