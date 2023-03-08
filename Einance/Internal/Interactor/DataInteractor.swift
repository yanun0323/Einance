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
    
    func DoTx<T>(_ log: String, _ action: () throws -> T?) -> T? where T: Any {
        return System.Catch(log) {
            return try repo.Tx {
                return try action()
            }
        }
    }
    
    func UpdateMonthlyBudget(_ budget: Budget) {
        let nextStartDate = calculateStartDate()
        if !budget.IsExpired(nextStartDate) {
            return
        }
        DoTx("update monthly budget") {
            let b = Budget(start: nextStartDate)
            b.id = try repo.CreateBudget(b)
            
            for card in budget.book {
                try addNextCardToBudget(b, card)
            }
            
            b.balance = b.amount - b.cost
            try repo.UpdateBudget(b)
            
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
        stopTheWorld(true)
        System.Async {
            return DoTx("publish current budget") {
                return try repo.GetLastBudget()
            }
        } main: { b in
            appstate.budgetPublisher.send(b)
            stopTheWorld(false)
        }
    }
    
    
    // MARK: Budget
    func GetBudget(_ id: Int64) -> Budget? {
        return DoTx("get budget by id") {
            return try repo.GetBudget(id)
        }
    }
    
    
    func CreateFirstBudget() {
        stopTheWorld(true)
        System.Async {
            DoTx("create first budget") {
                let startDate = calculateStartDate()
                _ = try repo.CreateBudget(Budget(start: startDate))
            }
        } main: {
            PublishCurrentBudget()
            stopTheWorld(false)
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
    
    /**
     Create card into budget and update budget
     */
    func CreateCard(_ b: Budget, name: String, amount: Decimal, display: Card.Display, color: Color, fixed: Bool ) {
        DoTx("create card") {
            let c = Card(budgetID: b.id, index: b.book.count, name: name, amount: amount, display: display, color: color, fixed: fixed || display == .forever)
            
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
    func UpdateCard(_ b: Budget, _ c: Card, name: String, index: Int, amount: Decimal, color: Color, display: Card.Display, fixed: Bool) {
        DoTx("update card") {
            let updateOrder = (c.index != index)
            b.amount = b.amount - c.amount + amount
            b.balance = b.amount - b.cost
            
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
            
            b.amount -= c.amount
            b.cost -= c.cost
            b.balance = b.amount - b.cost
            for i in 0 ..< b.book.count {
                b.book[i].index = i
                try repo.UpdateCard(b.book[i])
            }
            
            try repo.UpdateBudget(b)
            try repo.DeleteCard(c.id)
            try repo.DeleteRecords(c.id)
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
            b.cost += r.cost
            b.balance = b.amount - b.cost
            
            r.id = try repo.CreateRecord(r)
            
            if c.dateDict[r.date.key] == nil {
                c.dateDict[r.date.key] = Card.RecordSet()
            }
            c.dateDict[r.date.key]?.records.append(r)
            c.dateDict[r.date.key]?.cost += r.cost
            
            try repo.UpdateCard(c)
            try repo.UpdateBudget(b)
        }
    }
    
    /**
     Update card parameter and parent budget into database without updating records
     */
    func UpdateRecord(_ b: Budget, _ c: Card, _ r: Record, date: Date, cost: Decimal, memo: String, fixed: Bool) {
        DoTx("update record") {
            let key = r.date.key
            if c.dateDict[key] == nil {
                throw DataInteractorError.recordNotFound
            }
            let needSort = (r.date != date)
            
            c.dateDict[key]!.records.removeAll(where: { $0.id == r.id })
            c.dateDict[key]!.cost -= r.cost
            if c.dateDict[key]!.records.isEmpty {
                c.dateDict.removeValue(forKey: key)
            }
            
            c.cost = c.cost - r.cost + cost
            c.balance = c.amount - c.cost
            
            b.cost = b.cost - r.cost + cost
            b.balance = b.amount - b.cost
            
            r.date = date
            r.cost = cost
            r.memo = memo
            r.fixed = fixed
            
            let newKey = r.date.key
            if c.dateDict[newKey] == nil {
                c.dateDict[newKey] = Card.RecordSet()
            }
            c.dateDict[newKey]?.records.append(r)
            c.dateDict[newKey]?.cost += r.cost
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
            let key = r.date.key
            if c.dateDict[key] == nil {
                throw DataInteractorError.recordNotFound
            }
            
            c.dateDict[key]!.records.removeAll(where: { $0.id == r.id })
            c.dateDict[key]!.cost -= r.cost
            if c.dateDict[key]!.records.isEmpty {
                c.dateDict.removeValue(forKey: key)
            }
            
            c.cost -= r.cost
            c.balance = c.amount - c.cost
            b.cost -= r.cost
            b.balance = b.amount - b.cost
            
            try repo.DeleteBudget(r.id)
            try repo.UpdateCard(c)
            try repo.UpdateBudget(b)
        }
    }
    
#if DEBUG
    // MARK: - Debug
    func DebugForceMonthlyUpdate(_ budget: Budget) {
        let nextStartDate = calculateStartDate()
        if !budget.IsExpired(nextStartDate) {
            return
        }
        DoTx("update monthly budget") {
            let b = Budget(start: nextStartDate)
            b.id = try repo.CreateBudget(b)
            
            for card in budget.book {
                try addNextCardToBudget(b, card)
            }
            
            b.balance = b.amount - b.cost
            try repo.UpdateBudget(b)
            
            PublishCurrentBudget()
        }
    }
    
    func DebugDeleteLastBudget() {
        DoTx("[DEBUG] delete all budgets") {
            let budgets = try repo.GetBudgets()
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
    private func stopTheWorld(_ stop: Bool) {
        appstate.stopTheWorldPublisher.send(stop)
    }
    
    private func calculateStartDate() -> Date {
        let startDay = repo.GetBaseDateNumber() ?? 1
        var startDate = Date.now.firstDayOfMonth.AddDay(startDay-1)
        if Date.now < startDate {
            startDate = startDate.AddMonth(-1)
        }
        return startDate
    }
    
    private func addNextCardToBudget(_ b: Budget, _ card: Card) throws {
        if card.display == .forever {
            card.budgetID = b.id
            card.index = b.book.count
            b.amount += card.amount
            b.cost += card.cost
            b.book.append(card)
            try repo.UpdateCard(card)
            return
        }
        
        if !card.fixed { return }
        
        /* card.fixed == true, then -> */
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

        for (_, set) in card.dateDict {
            for record in set.records {
                if !record.fixed { continue }
                let r = Record(
                    cardID: c.id,
                    date: b.start,
                    cost: record.cost,
                    memo: record.memo,
                    fixed: record.fixed
                )
                c.cost += r.cost
                _ = try repo.CreateRecord(r)
            }
        }
        c.balance = c.amount - c.cost
        b.amount += card.amount
        b.cost += card.cost
        b.book.append(card)
        try repo.UpdateCard(c)
    }
}
