import SwiftUI
import UIComponent

struct DataInteractor {
    private var appstate: AppState
    private var repo: Repository
    
    init(appstate: AppState, repo: Repository) {
        self.appstate = appstate
        self.repo = repo
    }
}

extension DataInteractor {
    func SetCurrentBudget(_ b: Budget) {
        System.Invoke("set current budget") {
            try repo.SetCurrentBudget(b)
            try repo.UpdateBudget(b)
        }
        
        System.Async {
            appstate.updateBudgetIDPublisher.send(b.id)
        }
    }
    
    func CurrentBudget() -> Budget {
        return System.Invoke("get current budget") {
            let baseDateNumber = repo.GetBaseDateNumber() ?? 1
            return try repo.GetCurrentBudget(baseDateNumber)
        }!
    }
    
    func GetBudget(_ id: Int64) -> Budget? {
        return System.Invoke("get budget by id") {
            return try repo.GetBudget(id)
        }
    }
    
    func CreateCard(_ c: Card) -> Int64 {
        return System.Invoke("create card") {
            return try repo.CreateCard(c)
        }!
    }
    
    func DebugGetBudgetsCount() -> Int {
        return System.Invoke("[DEBUG] get budgets count") {
            return try repo.GetBudgets()
        }?.count ?? 0
    }
    
    func DebugCreateBudget() {
        System.Invoke("[DEBUG] create budget") {
            let id = try repo.CreateBudget(Budget(start:.now.firstDayOfMonth))
            print("INSERTED ID: \(id)")
        }
    }
    
    func DebugDeleteAllBudgets() {
        System.Invoke("[DEBUG] delete all budgets") {
            let budgets = try repo.GetBudgets()
            for b in budgets {
                try repo.DeleteBudget(b.id)
            }
        }
    }
}
