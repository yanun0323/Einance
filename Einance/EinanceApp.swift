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
    @State private var showV2Content: Bool = true
#if DEBUG
    private let container: DIContainer = .init(isMock: true)
#else
    private let container: DIContainer = .init(isMock: false)
#endif
    var body: some Scene {
        WindowGroup {
            contentViewRouter()
                .inject(container)
                .preferredColorScheme(appearance)
                .environment(\.locale, self.locale)
                .backgroundColor(.background, ignoresSafeAreaEdges: .all)
                .onReceived(container.appstate.contentViewV2Publisher) { showV2Content = $0 }
                .onReceived(container.appstate.appearancePublisher) { appearance = $0 }
                .onReceived(container.appstate.localePublisher) { locale = $0 }
                .onAppeared { appearance = container.interactor.setting.GetAppearance() }
                .onAppeared { locale = container.interactor.setting.GetLocale() }
        }
    }
    
    @ViewBuilder
    private func contentViewRouter() -> some View {
        if showV2Content {
            ContentViewV2()
        } else {
            ContentView()
        }
    }
}
