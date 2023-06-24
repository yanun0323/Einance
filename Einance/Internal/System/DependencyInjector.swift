import SwiftUI
import Ditto
import WatchConnectivity
extension DIContainer {
    var appstate: AppState { AppState.get() }
    var interactor: Interactor { Interactor.get(isMock: self.isMock) }
    
    func setup() {
        _ = appstate
        _ = interactor
    }
}

struct Interactor {
    private static var `default`: Interactor? = nil
    
    var common: CommonInteractor
    var system: SystemInteractor
    var setting: UserSettingInteractor
    var data: DataInteractor
    var watch: WatchInteractor
    
    init(appstate: AppState, isMock: Bool) {
        let repo: Repository = Dao()
        var dbName: String? = UserDefaults.mockDBName
        
        #if DEBUG
        if dbName == nil {
            dbName = "development"
        }
        #endif
        repo.setup(dbName, isMock: isMock, migrate: true)
        repo.trace { sql in
            print("[TRACE] \(sql)")
        }
        
        self.common = CommonInteractor()
        self.system = SystemInteractor(appstate: appstate, repo: repo)
        self.setting = UserSettingInteractor(appstate: appstate, repo: repo, common: common)
        self.data = DataInteractor(appstate: appstate, repo: repo, common: common, setting: setting)
        self.watch = WatchInteractor(appstate: appstate, repo: repo, setting: setting)
        watch.setupSubscribe()
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
