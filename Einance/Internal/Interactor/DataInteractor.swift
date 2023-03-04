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

enum DataInteractorError: Error {
    case budgetNotFound
    case cardNotFound
    case recordNotFound
}

// MARK: Public Function
extension DataInteractor {
    // MARK: - Current Budget
    func IsZeroBudget() -> Bool {
        guard let count = System.Catch("get budget count", {
            return try repo.GetBudgetCount()
        }) else {
            return true
        }
        return count == 0
    }
    
    func GetCurrentBudget() -> Budget? {
        return System.Catch("get current budget") {
            return try repo.GetLastBudget()
        }
    }
    
    func GetCurrentBudgetWithoutChildren() -> Budget? {
        return System.Catch("get current budget id") {
            return try repo.GetLastBudgetWithoutChildren()
        }
    }
    
    // MARK: Budget
    func GetBudget(_ id: Int64) -> Budget? {
        return System.Catch("get budget by id") {
            return try repo.GetBudget(id)
        }
    }
    
    
    func CreateBudget() {
        System.Catch("create budget") {
            let id = try repo.CreateBudget(Budget(start:.now.firstDayOfMonth))
            publishBudgetID(id)
        }
    }
    
    /**
     Update budget parameter into database without updating cards
     */
    func UpdateBudget(_ b: Budget) {
        System.Catch("update budget") {
            try repo.UpdateBudget(b)
        }
    }
    
    // MARK: - Card
    
    func IsZeroCardOfBudget(_ id: Int64) -> Bool {
        guard let count = System.Catch("is any book of budget", {
            return try repo.GetCardCountOfBudget(id)
        }) else {
            return true
        }
        
        return count == 0
    }
    
    func GetCard(_ id: Int64) -> Card? {
        return System.Catch("get card") {
            return try repo.GetCard(id)
        }
    }
    
    /**
     Create card into budget and update budget
     */
    func CreateCard(_ b: Budget, name: String, amount: Decimal, display: Card.Display, color: Color, fixed: Bool
    ) {
        System.Catch("create card") {
            let c = Card(budgetID: b.id, index: b.book.count, name: name, amount: amount, display: display, color: color, fixed: fixed)
            
            b.amount += amount
            b.balance = b.amount - b.cost
            
            c.id = try repo.CreateCard(c)
            
            b.book.append(c)
            
            try repo.UpdateBudget(b)
        }
    }
    
    /**
    Update card parameter and parent budget into database without updating records
     */
    func UpdateCard(_ b: Budget, _ c: Card, name: String, amount: Decimal, color: Color, display: Card.Display, fixed: Bool) {
        System.Catch("update card") {
            b.amount = b.amount - c.amount + amount
            b.balance = b.amount - b.cost
            
            c.name = name
            c.amount = amount
            c.balance = c.amount - c.cost
            c.color = color
            c.display = display
            c.fixed = fixed

            try repo.UpdateCard(c)
            try repo.UpdateBudget(b)
        }
    }
    
    // MARK: - Record
    
    /**
     Create record into card and update budget and card
     */
    func CreateRecord(_ b: Budget, _ c: Card, date: Date, cost: Decimal, memo: String, fixed: Bool) {
        System.Catch("create record") {
            let r = Record(id: b.id, cardID: c.id, date: date, cost: cost, memo: memo, fixed: fixed)
            
            c.cost += r.cost
            c.balance = c.amount - c.cost
            b.cost += r.cost
            b.balance = b.amount - b.cost
            
            r.id = try repo.CreateRecord(r)
            
            if c.dateDict[r.date.unixDay] == nil {
                c.dateDict[r.date.unixDay] = Card.RecordSet()
            }
            c.dateDict[r.date.unixDay]?.records.append(r)
            c.dateDict[r.date.unixDay]?.cost += r.cost
            
            try repo.UpdateCard(c)
            try repo.UpdateBudget(b)
        }
    }
    
    /**
     Update card parameter and parent budget into database without updating records
     */
    func UpdateRecord(_ b: Budget, _ c: Card, _ r: Record, date: Date, cost: Decimal, memo: String, fixed: Bool) {
        System.Catch("update record") {
            c.cost = c.cost - r.cost + cost
            c.balance = c.amount - c.cost
            
            b.cost = b.cost - r.cost + cost
            b.balance = b.amount - b.cost
            
            r.date = date
            r.cost = cost
            r.memo = memo
            r.fixed = fixed
            
            try repo.UpdateRecord(r)
            try repo.UpdateCard(c)
            try repo.UpdateBudget(b)
        }
    }
    
#if DEBUG
    // MARK: - Debug
    func DebugGetBudgetsCount() -> Int {
        return System.Catch("[DEBUG] get budgets count") {
            return try repo.GetBudgets()
        }?.count ?? -1
    }
    
    func DebugCreateBudget() {
        System.Catch("[DEBUG] create budget") {
            let id = try repo.CreateBudget(Budget(start:.now.firstDayOfMonth))
            print("INSERTED ID: \(id)")
            publishBudgetID(id)
        }
    }
    
    func DebugDeleteAllBudgets() {
        System.Catch("[DEBUG] delete all budgets") {
            let budgets = try repo.GetBudgets()
            for b in budgets {
                try repo.DeleteBudget(b.id)
            }
        }
    }
#endif
}

// MARK: Private Function
extension DataInteractor {
    private func publishBudgetID(_ id: Int64) {
        System.Async {
            appstate.updateBudgetIDPublisher.send(id)
        }
    }
}
