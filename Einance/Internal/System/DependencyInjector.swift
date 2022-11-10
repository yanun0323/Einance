//
//  DependencyInjector.swift
//  Einance
//
//  Created by YanunYang on 2022/11/10.
//

import Foundation

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
    
    init(isMock: Bool, appstate: AppState) {
        let dao: Repository = isMock ? MockDao() : Dao()
        self.data = DataInteractor(appstate: appstate, repo: dao)
    }
}
