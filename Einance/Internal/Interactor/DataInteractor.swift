import SwiftUI
import Ditto

struct DataInteractor {
    private var appstate: AppState
    private var repo: Repository
    private var common: CommonInteractor
    private var setting: UserSettingInteractor
    
    init(appstate: AppState, repo: Repository, common: CommonInteractor, setting: UserSettingInteractor) {
        self.appstate = appstate
        self.repo = repo
        self.common = common
        self.setting = setting
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
    
    func doTx<T>(_ log: String, _ action: () throws -> T?) -> T? where T: Any {
        return System.doCatch(log) {
            return try repo.Tx {
                return try action()
            }
        }
    }
    
    func UpdateMonthlyBudget(_ budget: Budget, force: Bool = false) -> Bool {
        return doTx("update monthly budget") {
            let nextStartDate = common.CalculateNextDate(budget.startAt, days: setting.GetBaseDateNumber())
            var archivedDate = nextStartDate.addDay(-1)
            if force {
                archivedDate = Date.now.addDay(-1).key
                if try repo.IsDateBudgetArchived(archivedDate) {
                    return false
                }
            }
            
            budget.archiveAt = nextStartDate.addDay(-1)
            
            let b = Budget(startAt: nextStartDate)
            b.id = try repo.CreateBudget(b)
            
            for card in budget.book {
                try addNextCardToBudget(b, card)
            }
            
            b.balance = b.amount - b.cost
            try repo.UpdateBudget(b)
            try repo.UpdateBudget(budget)
            
            PublishCurrentBudgetFromDB()
            return true
        } ?? false
    }
    
    // MARK: - Current Budget
    
    func GetCurrentBudget() -> Budget? {
        return doTx("get current budget") {
            return try repo.GetLastBudget()
        }
    }
    
    func PublishCurrentBudgetFromDB() {
        System.doCatch("publish current budget from DB") {
            print("publish current budget from DB")
            let b = try repo.GetLastBudget()
            appstate.budgetPublisher.send(b)
        }
    }
    
    
    // MARK: Budget
    
    func IsDateBudgetArchived(_ archivedAt: Date) -> Bool {
        return doTx("is date budget archived at") {
            return try repo.IsDateBudgetArchived(archivedAt)
        } ?? true
    }
    
    func GetBudget(_ id: Int64) -> Budget? {
        return doTx("get budget by id") {
            return try repo.GetBudget(id)
        }
    }
    
    func ListBudgets() -> [Budget] {
        return doTx("list budgets") {
            return try repo.ListBudgets()
        } ?? []
    }
    
    
    func CreateFirstBudget() {
        doTx("create first budget") {
            _ = try repo.CreateBudget(Budget(startAt: setting.GetFirstStartDate()))
            PublishCurrentBudgetFromDB()
        }
    }
    
    // MARK: - Card
    
    func ListCards(by chainID: UUID) -> [Card] {
        return doTx("list cards by chainID") {
            return try repo.ListCards(chainID)
        } ?? []
    }
    
    func ListChainableCards() -> [Card] {
        return doTx("list chainable cards") {
            return try repo.ListChainableCards()
        } ?? []
    }
    
    func ListChainableCards(by budget: Budget) -> [Card] {
        return doTx("list chainable cards with budget ID") {
            return try repo.ListChainableCards(budget)
        } ?? []
    }
    
    func GetCard(_ id: Int64) -> Card? {
        return doTx("get card") {
            return try repo.GetCard(id)
        }
    }
    
    func GetArchivedCards() -> [Card] {
        return doTx("get archived card") {
            return try repo.ListCards(-1)
        } ?? []
    }
    
    /**
     Create card into budget and update budget
     */
    func CreateCard(_ b: Budget, name: String, amount: Decimal, display: Card.Display, fColor: Color, bColor: Color, gColor: Color?, pinned: Bool ) {
        doTx("create card") {
            let c = Card(budgetID: b.id, index: b.book.count, name: name, amount: amount, display: display, fColor: fColor, bColor: bColor, gColor: gColor, pinned: pinned || display == .forever)
            
            if !c.isForever {
                b.amount += amount
                b.balance = b.amount - b.cost
            }
            
            c.id = try repo.CreateCard(c)
            b.book.append(c)
            
            b.updatedAt = Date.now.unix
            try repo.UpdateBudget(b)
        }
        
        System.async {
            appstate.budgetPublisher.send(b)
        }
    }
    
    /**
    Update card parameter and parent budget into database without updating records
     */
    func UpdateCard(_ b: Budget, _ c: Card, name: String, index: Int, amount: Decimal, fColor: Color, bColor: Color, gColor: Color?, display: Card.Display, pinned: Bool) {
        doTx("update card") {
            let updateOrder = (c.index != index)
            let changeFixed = (c.pinned != pinned && !pinned)
            
            if !c.isForever {
                b.amount = b.amount - c.amount + amount
                b.balance = b.amount - b.cost
            }
            
            c.name = name
            c.index = index
            c.amount = amount
            c.balance = c.amount - c.cost
            c.fColor = fColor
            c.bColor = bColor
            c.gColor = gColor
            c.display = display
            c.pinned = pinned || display == .forever
            
            if updateOrder {
                for i in 0 ..< b.book.count {
                    b.book[i].index = i
                    try repo.UpdateCard(b.book[i])
                }
            }
            
            if changeFixed {
                for (_, v) in c.dateDict {
                    for r in v.records {
                        if r.pinned {
                            r.pinned = false
                            c.MoveRecordFixedToDict(r)
                            try repo.UpdateRecord(r)
                        }
                    }
                }
            }
            
            b.updatedAt = Date.now.unix
            try repo.UpdateCard(c)
            try repo.UpdateBudget(b)
        }
        
        System.async {
            appstate.budgetPublisher.send(b)
        }
    }
    
    func UpdateCardsOrder(_ b: Budget) {
        doTx("update card order") {
            for card in b.book {
                try repo.UpdateCard(card)
            }
            
            b.updatedAt = Date.now.unix
            try repo.UpdateBudget(b)
        }
        
        System.async {
            appstate.budgetPublisher.send(b)
        }
    }
    
    func DeleteCard(_ b: Budget, _ c: Card) {
        doTx("delete card") {
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
            
            b.updatedAt = Date.now.unix
            try repo.UpdateBudget(b)
            try repo.DeleteCard(c.id)
            try repo.DeleteRecords(c.id)
            try repo.DeleteTags(c.chainID)
        }
        
        System.async {
            appstate.budgetPublisher.send(b)
        }
    }
    
    func ArchiveCard(_ b: Budget, _ c: Card) {
        doTx("archive card") {
            if !c.isForever { return }
            b.book.removeAll(where: { $0.id == c.id })
            c.budgetID = -1
            b.updatedAt = Date.now.unix
            try repo.UpdateCard(c)
            try repo.DeleteTags(c.chainID)
            try repo.UpdateBudget(b)
        }
        
        System.async {
            appstate.budgetPublisher.send(b)
        }
    }
    
    // MARK: - Record
    
    private func listTodayRecords() -> [Record] {
        return doTx("list today's records") {
            guard let date = Date(from: Date.now.string("yyyyMMdd"), "yyyyMMdd") else {
                throw Err.transDateFailed
            }
            return try repo.ListRecords(after: date)
        } ?? []
    }
    
    func ListRecords(by cardID: Int64) -> [Record] {
        return doTx("list records by cardID") {
            return try repo.ListRecords(cardID)
        } ?? []
    }
    
    /**
     Create record into card and update budget and card
     */
    func CreateRecord(_ b: Budget, _ c: Card, date: Date, cost: Decimal, memo: String, pinned: Bool) {
        doTx("create record") {
            let r = Record(id: b.id, cardID: c.id, date: date, cost: cost, memo: memo, pinned: pinned)
            
            c.cost += r.cost
            c.balance = c.amount - c.cost
            if !c.isForever {
                b.cost += r.cost
                b.balance = b.amount - b.cost
            }
            
            r.id = try repo.CreateRecord(r)
            
            if pinned {
                c.AddRecordToFixed(r)
            } else {
                c.AddRecordToDict(r)
            }
            
            b.updatedAt = Date.now.unix
            try repo.UpdateCard(c)
            try repo.UpdateBudget(b)
        }
        
        System.async {
            appstate.budgetPublisher.send(b)
        }
    }
    
    /**
     Update card parameter and parent budget into database without updating records
     */
    func UpdateRecord(_ b: Budget, _ c: Card, _ r: Record, date: Date, cost: Decimal, memo: String, pinned: Bool) {
        doTx("update record") {
            let needSort = (r.date != date) || pinned
            guard let oldCard = b.book.first(where: { $0.id == r.cardID}) else {
                throw Err.cardNotFound
            }
            if r.pinned {
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
            r.pinned = pinned
            
            if pinned {
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
            b.updatedAt = Date.now.unix
            try repo.UpdateRecord(r)
            try repo.UpdateCard(c)
            try repo.UpdateBudget(b)
        }
        
        System.async {
            appstate.budgetPublisher.send(b)
        }
    }
    
    func DeleteRecord(_ b: Budget, _ c: Card, _ r: Record) {
        doTx("delete record") {
            if r.pinned {
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
            
            b.updatedAt = Date.now.unix
            try repo.DeleteRecord(r.id)
            try repo.UpdateCard(c)
            try repo.UpdateBudget(b)
        }
        
        System.async {
            appstate.budgetPublisher.send(b)
        }
    }
    
    // MARK: - Tag
    
    func ListTags(_ chainID: UUID, _ type: TagType, _ updatedAt: Int) -> [Tag] {
        return doTx("list tags") {
            let hour = type == .number ? 5.0  : 4.5
            return try repo.ListTags(chainID, type, updatedAt, Int(hour * .hour), 20)
        } ?? []
    }
    
    func CreateTag(_ chainID: UUID, _ type: TagType, _ value: String, _ updatedAt: Int) {
        if unavailableTag(type, value: value) {
            #if DEBUG
            print("[WARN] unavailable value")
            #endif
            return
        }
        doTx("create tag") {
            if let tag = try repo.GetTag(chainID, type, value) {
                var t = tag
                t.count += 1
                t.key = (t.key + updatedAt) / 2
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
        
        doTx("edit tag: delete old tag") {
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
                try repo.UpdateTag(t)
            }
        }
        
        CreateTag(chainID, type, new, updatedAt)
    }
    
    func DeleteExpiredTags() {
        doTx("delete expired tags") {
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
    func UpdateAllCardColor() {
        doTx("[DEBUG] udpate all card color") {
            let rows = try SQL.getDriver().prepare(Card.table)
            for row in rows {
                let c = try Card.parse(row)
                try repo.UpdateCard(c)
            }
        }
    }
    
    func ListAllCard() -> [Card] {
        return doTx("[DEBUG] list all card") {
            var cs: [Card] = []
            let rows = try SQL.getDriver().prepare(Card.table)
            for row in rows {
                cs.append(try Card.parse(row))
            }
            return cs
        } ?? []
    }
    
    func Repo() -> Repository {
        return repo
    }
    
    func DebugDeleteLastBudget() {
        doTx("[DEBUG] delete all budgets") {
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
        
        if card.pinned {
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
            bColor: card.bColor,
            gColor: card.gColor,
            pinned: card.pinned
        )
        
        c.id = try repo.CreateCard(c)

        for record in card.pinnedArray {
            let r = Record(
                cardID: c.id,
                date: b.startAt,
                cost: record.cost,
                memo: record.memo,
                pinned: record.pinned
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
