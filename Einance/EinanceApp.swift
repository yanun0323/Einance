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
    private let container: DIContainer = .init(isMock: true)
    var body: some Scene {
        WindowGroup {
            ContentView()
                .inject(container)
                .preferredColorScheme(appearance)
                .onReceive(container.appstate.appearancePublisher) { output in
                    withAnimation {
                        appearance = output
                    }
                }
                .onAppear {
                    withAnimation {
                        appearance = container.interactor.setting.GetAppearance()
                    }
                }
        }
    }
}
