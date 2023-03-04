//
//  EinanceApp.swift
//  Einance
//
//  Created by YanunYang on 2022/11/10.
//

import SwiftUI
import UIComponent

@main
struct EinanceApp: App {
    @State private var appearance: ColorScheme? = nil
#if DEBUG
    private let container: DIContainer = .init(isMock: true)
#else
    private let container: DIContainer = .init(isMock: false)
#endif
    var body: some Scene {
        WindowGroup {
            ContentView(injector: container)
                .inject(container)
                .preferredColorScheme(appearance)
                .onReceive(container.appstate.appearancePublisher) { output in
                    withAnimation(.quick) {
                        appearance = output
                    }
                }
                .onAppear {
                    withAnimation(.quick) {
                        appearance = container.interactor.setting.GetAppearance()
                    }
                }
        }
    }
}
