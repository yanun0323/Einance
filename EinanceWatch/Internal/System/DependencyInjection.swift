import SwiftUI
import Ditto

extension DIContainer {
    var appstate: AppState { AppState.get() }
    var interactor: Interactor { Interactor.get(isMock: self.isMock) }
}

struct Interactor {
    private static var `default`: Interactor? = nil
    
    var watch: WatchInteractor
    
    init(appstate: AppState, isMock: Bool) {
        let repo: WatchRepository = Dao()
        repo.setup("test1", isMock: isMock, migrate: true)
        
        self.watch = WatchInteractor(appstate: appstate, repo: repo)
    }
}

extension Interactor {
    static func get(isMock: Bool) -> Self {
        if Self.default.isNil {
            Self.default = Interactor(appstate: AppState.get(), isMock: isMock)
        }
        return Self.default!
    }
}
