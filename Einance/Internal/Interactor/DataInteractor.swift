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
    
    func Do<T>(_ log: String, _ action: () throws -> T?) -> T? where T: Any {
        return System.Catch(log) {
            return try action()
        }
    }
    
    func DoTx<T>(_ log: String, _ action: () throws -> T?) -> T? where T: Any {
        return System.Catch(log) {
            return try repo.Tx {
                return try action()
            }
        }
    }
    
    func UpdateMonthlyBudget(_ budget: Budget, force: Bool = false) {
        DoTx("update monthly budget") {
            var nextStartDate = repo.GetNextStartDate(budget.startAt)
            if force {
                nextStartDate = Date(from: Date.now.String("yyyyMMdd", .US), .Numeric)!
            }
            budget.archiveAt = nextStartDate.AddDay(-1)
            
            let b = Budget(startAt: nextStartDate)
            b.id = try repo.CreateBudget(b)
            
            for card in budget.book {
                try addNextCardToBudget(b, card)
            }
            
            b.balance = b.amount - b.cost
            try repo.UpdateBudget(b)
            try repo.UpdateBudget(budget)
            
            PublishCurrentBudget()
        }
    }
    
    // MARK: - Current Budget
    
    func GetCurrentBudget() -> Budget? {
        return DoTx("get current budget") {
            return try repo.GetLastBudget()
        }
    }
    
    func PublishCurrentBudget() {
        Do("publish current budget") {
            print("publish current budget")
            let b = try repo.GetLastBudget()
            appstate.budgetPublisher.send(b)
        }
    }
    
    
    // MARK: Budget
    
    func GetBudget(_ id: Int64) -> Budget? {
        return DoTx("get budget by id") {
            return try repo.GetBudget(id)
        }
    }
    
    func ListBudgets() -> [Budget] {
        return DoTx("list budgets") {
            return try repo.ListBudgets()
        }!
    }
    
    
    func CreateFirstBudget() {
        DoTx("create first budget") {
            _ = try repo.CreateBudget(Budget(startAt: repo.GetFirstStartDate()))
            PublishCurrentBudget()
        }
    }
    
    /**
     Update budget parameter into database without updating cards
     */
    func UpdateBudget(_ b: Budget) {
        DoTx("update budget") {
            try repo.UpdateBudget(b)
        }
    }
    
    func DeleteBudget(_ b: Budget) {
        DoTx("delete budget") {
            try repo.Tx {
                try repo.DeleteBudget(b.id)
                try repo.DeleteCards(b.id)
                for card in b.book {
                    try repo.DeleteRecords(card.id)
                }
            }
        }
    }
    
    // MARK: - Card
    
    func GetCard(_ id: Int64) -> Card? {
        return DoTx("get card") {
            return try repo.GetCard(id)
        }
    }
    
    func  GetArchivedCards() -> [Card] {
        return DoTx("get archived card") {
            return try repo.ListCards(-1)
        }!
    }
    
    /**
     Create card into budget and update budget
     */
    func CreateCard(_ b: Budget, name: String, amount: Decimal, display: Card.Display, color: Color, fixed: Bool ) {
        DoTx("create card") {
            let c = Card(budgetID: b.id, index: b.book.count, name: name, amount: amount, display: display, color: color, fixed: fixed || display == .forever)
            
            if !c.isForever {
                b.amount += amount
                b.balance = b.amount - b.cost
            }
            
            c.id = try repo.CreateCard(c)
            b.book.append(c)
            
            try repo.UpdateBudget(b)
        }
    }
    
    /**
    Update card parameter and parent budget into database without updating records
     */
    func UpdateCard(_ b: Budget, _ c: Card, name: String, index: Int, amount: Decimal, color: Color, display: Card.Display, fixed: Bool) {
        DoTx("update card") {
            let updateOrder = (c.index != index)
            let changeFixed = (c.fixed != fixed && !fixed)
            
            if !c.isForever {
                b.amount = b.amount - c.amount + amount
                b.balance = b.amount - b.cost
            }
            
            c.name = name
            c.index = index
            c.amount = amount
            c.balance = c.amount - c.cost
            c.color = color
            c.display = display
            c.fixed = fixed || display == .forever
            
            if updateOrder {
                for i in 0 ..< b.book.count {
                    b.book[i].index = i
                    try repo.UpdateCard(b.book[i])
                }
            }
            
            if changeFixed {
                for (_, v) in c.dateDict {
                    for r in v.records {
                        if r.fixed {
                            r.fixed = false
                            c.MoveRecordFixedToDict(r)
                            try repo.UpdateRecord(r)
                        }
                    }
                }
            }
            
            try repo.UpdateCard(c)
            try repo.UpdateBudget(b)
        }
    }
    
    func UpdateCardsOrder(_ budget: Budget) {
        DoTx("update card order") {
            for card in budget.book {
                try repo.UpdateCard(card)
            }
        }
    }
    
    func DeleteCard(_ b: Budget, _ c: Card) {
        DoTx("delete card") {
            guard let index = b.book.firstIndex(where: { $0.id == c.id }) else {
                throw DataInteractorError.cardNotFound
            }
            
            b.book.remove(at: index)
            
            if !c.isForever {
                b.amount -= c.amount
                b.cost -= c.cost
                b.balance = b.amount - b.cost
            }
            for i in 0 ..< b.book.count {
                b.book[i].index = i
                try repo.UpdateCard(b.book[i])
            }
            
            try repo.UpdateBudget(b)
            try repo.DeleteCard(c.id)
            try repo.DeleteRecords(c.id)
        }
    }
    
    func ArchiveCard(_ b: Budget, _ c: Card){
        DoTx("archive card") {
            if !c.isForever { return }
            b.book.removeAll(where: { $0.id == c.id })
            c.budgetID = -1
            try repo.UpdateCard(c)
        }
    }
    
    // MARK: - Record
    
    /**
     Create record into card and update budget and card
     */
    func CreateRecord(_ b: Budget, _ c: Card, date: Date, cost: Decimal, memo: String, fixed: Bool) {
        DoTx("create record") {
            let r = Record(id: b.id, cardID: c.id, date: date, cost: cost, memo: memo, fixed: fixed)
            
            c.cost += r.cost
            c.balance = c.amount - c.cost
            if !c.isForever {
                b.cost += r.cost
                b.balance = b.amount - b.cost
            }
            
            r.id = try repo.CreateRecord(r)
            
            if fixed {
                c.AddRecordToFixed(r)
            } else {
                c.AddRecordToDict(r)
            }
            
            try repo.UpdateCard(c)
            try repo.UpdateBudget(b)
        }
    }
    
    /**
     Update card parameter and parent budget into database without updating records
     */
    func UpdateRecord(_ b: Budget, _ c: Card, _ r: Record, date: Date, cost: Decimal, memo: String, fixed: Bool) {
        DoTx("update record") {
            let needSort = (r.date != date) || fixed
            
            if r.fixed {
                c.RemoveRecordFromFixed(r)
            } else {
                c.RemoveRecordFromDict(r)
            }
            
            c.cost = c.cost - r.cost + cost
            c.balance = c.amount - c.cost
            
            if !c.isForever {
                b.cost = b.cost - r.cost + cost
                b.balance = b.amount - b.cost
            }
            
            r.date = date
            r.cost = cost
            r.memo = memo
            r.fixed = fixed
            
            if fixed {
                c.AddRecordToFixed(r)
            } else {
                c.AddRecordToDict(r)
            }
            
            if needSort {
                c.dateDict.sort()
            }
            
            try repo.UpdateRecord(r)
            try repo.UpdateCard(c)
            try repo.UpdateBudget(b)
        }
    }
    
    func DeleteRecord(_ b: Budget, _ c: Card, _ r: Record) {
        DoTx("delete record") {
            if r.fixed {
                c.RemoveRecordFromFixed(r)
            } else {
                c.RemoveRecordFromDict(r)
            }
            
            c.cost -= r.cost
            c.balance = c.amount - c.cost
            
            if !c.isForever {
                b.cost -= r.cost
                b.balance = b.amount - b.cost
            }
            
            try repo.DeleteRecord(r.id)
            try repo.UpdateCard(c)
            try repo.UpdateBudget(b)
        }
    }
    
#if DEBUG
    
    func DebugDeleteLastBudget() {
        DoTx("[DEBUG] delete all budgets") {
            let budgets = try repo.ListBudgets()
            if budgets.isEmpty { return }
            try repo.DeleteBudget(budgets[0].id)
        }
    }
    
    private func _Sleep(_ second: Int) throws {
        let t = second * 100000
        for _ in 0...t {
            _ = try repo.GetBudgetCount()
        }
    }
#endif
}

// MARK: Private Function
extension DataInteractor {
    
    private func addNextCardToBudget(_ b: Budget, _ card: Card) throws {
        if card.display == .forever {
            try handleCardForever(b, card)
            return
        }
        
        if !card.fixed { return }
        
        try handleCardFixed(b, card)
    }
    
    private func handleCardForever(_ b: Budget, _ card: Card) throws {
        card.budgetID = b.id
        card.index = b.book.count
        b.book.append(card)
        try repo.UpdateCard(card)
    }
    
    private func handleCardFixed(_ b: Budget, _ card: Card) throws {
        let c = Card(
            budgetID: b.id,
            index: b.book.count,
            name: card.name,
            amount: card.amount,
            display: card.display,
            records: [],
            color: card.color,
            fixed: card.fixed
        )
        
        c.id = try repo.CreateCard(c)

        for record in card.fixedArray {
            let r = Record(
                cardID: c.id,
                date: b.startAt,
                cost: record.cost,
                memo: record.memo,
                fixed: record.fixed
            )
            c.cost += r.cost
            _ = try repo.CreateRecord(r)
        }
        
        c.balance = c.amount - c.cost
        b.amount += c.amount
        b.cost += c.cost
        b.book.append(c)
        try repo.UpdateCard(c)
    }
}
