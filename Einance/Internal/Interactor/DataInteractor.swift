//
//  DataInteractor.swift
//  Einance
//
//  Created by YanunYang on 2022/11/11.
//

import Foundation

struct DataInteractor {
    private var appstate: AppState
    private var repo: Repository
    
    init(appstate: AppState, repo: Repository) {
        self.appstate = appstate
        self.repo = repo
    }
}

extension DataInteractor {
    func CurrentBudget() -> Budget {
        return repo.GetBudget()
    }
    
    func CurrentCard() -> Card {
        return repo.GetCurrentCard()
    }
}
