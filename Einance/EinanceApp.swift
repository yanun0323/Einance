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
    private let container: DIContainer = .init(isMock: true)
    var body: some Scene {
        WindowGroup {
            ContentView(injector: container)
                .inject(container)
        }
    }
}
