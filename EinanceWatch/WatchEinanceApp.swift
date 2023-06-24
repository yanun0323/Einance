import SwiftUI
import Ditto

@main
struct EinanceWatch_App: App {
#if DEBUG
    private let container: DIContainer = .init(isMock: true)
#else
    private let container: DIContainer = .init(isMock: false)
#endif
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .inject(container)
        }
    }
}
