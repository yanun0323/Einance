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

enum Err: Error {
    case budgetNotFound
    case cardNotFound
    case recordNotFound
    case emptyValue
    case transDateFailed
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
    
    func UpdateMonthlyBudget(_ budget: Budget, force: Bool = false) -> Bool {
        return DoTx("update monthly budget") {
            let nextStartDate = Interactor.CalculateNextDate(budget.startAt, days: repo.GetBaseDateNumber())
            var archivedDate = nextStartDate.AddDay(-1)
            if force {
                archivedDate = Date.now.AddDay(-1).key
                if try repo.IsDateBudgetArchived(archivedDate) {
                    return false
                }
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
            return true
        } ?? false
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
    
    func IsDateBudgetArchived(_ archivedAt: Date) -> Bool {
        return DoTx("is date budget archived at") {
            return try repo.IsDateBudgetArchived(archivedAt)
        } ?? true
    }
    
    func GetBudget(_ id: Int64) -> Budget? {
        return DoTx("get budget by id") {
            return try repo.GetBudget(id)
        }
    }
    
    func ListBudgets() -> [Budget] {
        return DoTx("list budgets") {
            return try repo.ListBudgets()
        } ?? []
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
    
    func ListCards(by chainID: UUID) -> [Card] {
        return DoTx("list cards by chainID") {
            return try repo.ListCards(chainID)
        } ?? []
    }
    
    func ListChainableCards() -> [Card] {
        return DoTx("list chainable cards") {
            return try repo.ListChainableCards()
        } ?? []
    }
    
    func ListChainableCards(by budget: Budget) -> [Card] {
        return DoTx("list chainable cards with budget ID") {
            return try repo.ListChainableCards(budget)
        } ?? []
    }
    
    func GetCard(_ id: Int64) -> Card? {
        return DoTx("get card") {
            return try repo.GetCard(id)
        }
    }
    
    func GetArchivedCards() -> [Card] {
        return DoTx("get archived card") {
            return try repo.ListCards(-1)
        } ?? []
    }
    
    /**
     Create card into budget and update budget
     */
    func CreateCard(_ b: Budget, name: String, amount: Decimal, display: Card.Display, fontColor: Color, color: Color, fixed: Bool ) {
        DoTx("create card") {
            let c = Card(budgetID: b.id, index: b.book.count, name: name, amount: amount, display: display, fontColor: fontColor, color: color, fixed: fixed || display == .forever)
            
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
    func UpdateCard(_ b: Budget, _ c: Card, name: String, index: Int, amount: Decimal, fontColor: Color, color: Color, display: Card.Display, fixed: Bool) {
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
            c.fontColor = fontColor
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
                throw Err.cardNotFound
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
            try repo.DeleteTags(c.chainID)
        }
    }
    
    func ArchiveCard(_ b: Budget, _ c: Card){
        DoTx("archive card") {
            if !c.isForever { return }
            b.book.removeAll(where: { $0.id == c.id })
            c.budgetID = -1
            try repo.UpdateCard(c)
            try repo.DeleteTags(c.chainID)
        }
    }
    
    // MARK: - Record
    
    private func listTodayRecords() -> [Record] {
        return DoTx("list today's records") {
            guard let date = Date(from: Date.now.String("yyyyMMdd"), "yyyyMMdd") else {
                throw Err.transDateFailed
            }
            return try repo.ListRecords(after: date)
        } ?? []
    }
    
    func ListRecords(by cardID: Int64) -> [Record] {
        return DoTx("list records by cardID") {
            return try repo.ListRecords(cardID)
        } ?? []
    }
    
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
            guard let oldCard = b.book.first(where: { $0.id == r.cardID}) else {
                throw Err.cardNotFound
            }
            if r.fixed {
                oldCard.RemoveRecordFromFixed(r)
            } else {
                oldCard.RemoveRecordFromDict(r)
            }
            
            oldCard.cost = oldCard.cost - r.cost
            oldCard.balance = oldCard.amount - oldCard.cost
            
            if !oldCard.isForever {
                b.cost = b.cost - r.cost
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
            
            c.cost = c.cost + cost
            c.balance = c.amount - c.cost
            if !c.isForever {
                b.cost = b.cost + cost
                b.balance = b.amount - b.cost
            }
            r.cardID = c.id
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
    
    // MARK: - Tag
    
    func ListTags(_ chainID: UUID, _ type: TagType, _ updatedAt: Int) -> [Tag] {
        return DoTx("list tags") {
            return try repo.ListTags(chainID, type, updatedAt, Int(4 * .hour), 20)
        } ?? []
    }
    
    func CreateTag(_ chainID: UUID, _ type: TagType, _ value: String, _ updatedAt: Int) {
        if unavailableTag(type, value: value) {
            #if DEBUG
            print("[WARN] unavailable value")
            #endif
            return
        }
        DoTx("create tag") {
            if let tag = try repo.GetTag(chainID, type, value) {
                var t = tag
                t.count += 1
                t.key = updatedAt
                try repo.UpdateTag(t)
            } else {
                _ = try repo.CreateTag(Tag(chainID: chainID, type: type, value: value, count: 1, key: updatedAt))
            }
        }
    }
    
    func EditTag(_ chainID: UUID, _ type: TagType, _ updatedAt: Int, old : String, new : String) {
        if old == new {
            #if DEBUG
            print("[WARN] same tag value: \(old)")
            #endif
            return
        }
        DoTx("edit tag: delete old tag") {
            if unavailableTag(type, value: old) {
                #if DEBUG
                print("[WARN] unavailable old tag")
                #endif
                return
            }
            
            guard let tag = try repo.GetTag(chainID, type, old) else {
                #if DEBUG
                print("[WARN] cannot find old tag in database")
                #endif
                return
            }
            
            if tag.count <= 1 {
                try repo.DeleteTag(tag.id)
            } else {
                var t = tag
                t.count -= 1
                t.key = updatedAt
                try repo.UpdateTag(t)
            }
        }
        
        CreateTag(chainID, type, new, updatedAt)
    }
    
    func DeleteExpiredTags() {
        DoTx("delete expired tags") {
            let interval = TimeInterval.day * -15
            let date = Date.now.addingTimeInterval(interval)
            try repo.DeleteTags(before: date)
        }
    }

    
    private func unavailableTag(_ type: TagType, value: String) -> Bool {
        let v = value.trimmingCharacters(in: [" "])
        switch type {
            case .text:
                return v.isEmpty
            case .number:
                guard let n = Decimal(string: value) else { return true }
                return n.isZero
            default:
                return true
        }
    }
#if DEBUG
    
    func Repo() -> Repository {
        return repo
    }
    
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
        
        if card.fixed {
            try handleCardFixed(b, card)
            return
        }
        
        try repo.DeleteTags(card.chainID)
    }
    
    private func handleCardForever(_ b: Budget, _ card: Card) throws {
        card.budgetID = b.id
        card.index = b.book.count
        b.book.append(card)
        try repo.UpdateCard(card)
    }
    
    private func handleCardFixed(_ b: Budget, _ card: Card) throws {
        let c = Card(
            chainID: card.chainID,
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

        for record in card.pinnedArray {
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
