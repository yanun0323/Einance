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
    @State private var locale: Locale = .current
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
                .environment(\.locale, self.locale)
                .backgroundColor(.background, ignoresSafeAreaEdges: .all)
                .onReceived(container.appstate.appearancePublisher) { appearance = $0 }
                .onReceived(container.appstate.localePublisher) { locale = $0 }
                .onAppeared { appearance = container.interactor.setting.GetAppearance() }
                .onAppeared { locale = container.interactor.setting.GetLocale() }
        }
    }
}
