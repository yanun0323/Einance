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

// MARK: Public Function
extension DataInteractor {
    // MARK: Current Budget
    func SetCurrentBudget(_ b: Budget) {
        System.Invoke("set current budget") {
            try repo.SetCurrentBudget(b)
            try repo.UpdateBudget(b)
        }
        publishBudgetID(b.id)
    }
    
    func CurrentBudget() -> Budget {
        return System.Invoke("get current budget") {
            let baseDateNumber = repo.GetBaseDateNumber() ?? 1
            return try repo.GetCurrentBudget(baseDateNumber)
        }!
    }
    
    // MARK: Budget
    func GetBudget(_ id: Int64) -> Budget? {
        return System.Invoke("get budget by id") {
            return try repo.GetBudget(id)
        }
    }
    
    func UpdateBudget(_ b: Budget) {
        System.Invoke("update budget") {
            try repo.UpdateBudget(b)
        }
        publishBudgetID(b.id)
    }
    
    // MARK: Card
    func CreateCard(_ c: Card) -> Int64 {
        return System.Invoke("create card") {
            return try repo.CreateCard(c)
        }!
    }
    
    func UpdateCard(_ c: Card) {
        System.Invoke("update card") {
            try repo.UpdateCard(c)
        }
    }
    
    // MARK: Record
    func CreateRecord(_ r: Record) -> Int64 {
        return System.Invoke("create record") {
            return try repo.CreateRecord(r)
        }!
    }
    
    // MARK: Debug
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

// MARK: Private Function
extension DataInteractor {
    private func publishBudgetID(_ id: Int64) {
        System.Async {
            appstate.updateBudgetIDPublisher.send(id)
        }
    }
}
