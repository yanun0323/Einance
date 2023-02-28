import SwiftUI

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
