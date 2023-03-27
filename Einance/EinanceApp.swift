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
            ContentView()
                .inject(container)
                .preferredColorScheme(appearance)
                .backgroundColor(.background, ignoresSafeAreaEdges: .all)
                .onReceived(container.appstate.appearancePublisher) { appearance = $0 }
                .onAppeared { appearance = container.interactor.setting.GetAppearance() }
        }
    }
}
