//
//  EinanceApp.swift
//  Einance
//
//  Created by YanunYang on 2022/11/10.
//

import SwiftUI
import Ditto

@main
struct EinanceApp: App {
    @State private var appearance: ColorScheme? = nil
    @State private var locale: Locale = .current
    
    @State var fColor: Color = .white
    @State var bColor: Color = .cyan
    @State var gColor: Color = .green
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
                .background(Color.background, ignoresSafeAreaEdges: .all)
                .onReceived(container.appstate.appearancePublisher) { appearance = $0 }
                .onReceived(container.appstate.localePublisher) { locale = $0 }
                .onAppeared { appearance = container.interactor.setting.GetAppearance() }
                .onAppeared { locale = container.interactor.setting.GetLocale() }
        }
    }
    
    @ViewBuilder
    private func contentViewRouter() -> some View {
        ContentViewV2()
    }
}
