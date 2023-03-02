import SwiftUI

class DIContainer: ObservableObject {
    var appstate: AppState
    var interactor: Interactor
    
    init(isMock: Bool = false) {
        let appstate = AppState()
        self.appstate = appstate
        self.interactor = Interactor(isMock: isMock, appstate: appstate)
        
    }
}



struct Interactor {
    var data: DataInteractor
    var system: SystemInteractor
    var setting: UserSettingInteractor
    
    init(isMock: Bool, appstate: AppState) {
        let repo: Repository = Dao()
        _ = Sql.Init(isMock: isMock)
        
        self.data = DataInteractor(appstate: appstate, repo: repo)
        self.system = SystemInteractor(appstate: appstate, repo: repo)
        self.setting = UserSettingInteractor(appstate: appstate, repo: repo)
    }
}
