import SwiftUI
import SQLite
import Sworm


class P: Identifiable {
    
}

protocol DataDao {}

extension DataDao where Self: DataRepository {
    
    // MARK: - Setup
    
    func setup(_ dbName: String?, isMock: Bool, migrate: Bool = true) {
        let db = SQL.setup(dbName: dbName, isMock: isMock)
        var migration: [Migrator.Type] = []
        if migrate {
            migration = [
                Tag.self,
                Record.self,
                Card.self,
                Budget.self,
            ]
        }
        db.migrate(migration)
    }
    
    func trace( _ trace: ((String) -> Void)?) {
        SQL.getDriver().trace(trace)
    }
    
    // MARK: - Common
    
    func Tx<T>(_ action: () throws -> T?) throws -> T? where T: Any {
        var result: T?
        try SQL.getDriver().transaction {
            result = try action()
        }
        return result
    }
    
    // MARK: - Budgets
    
    func IsDateBudgetArchived(_ archivedAt: Date) throws -> Bool {
        let query = Budget.table.filter(Budget.archiveAt == archivedAt).exists
        return try SQL.getDriver().scalar(query)
    }

    
    func GetBudgetCount() throws -> Int {
        return try countBudget()
    }
    
    func ListBudgets() throws -> [Budget] {
        var budgets: [Budget] = []
        let result = try SQL.getDriver().prepare(Budget.table.order(Budget.id.desc))
        for row in result {
            let b = try queryBudget(try Budget.parse(row))
            budgets.append(b)
        }
        return budgets
    }
    
    func ListBudgetsWithoutChildren() throws -> [Budget] {
        var budgets: [Budget] = []
        let result = try SQL.getDriver().prepare(Budget.table.order(Budget.id.desc))
        for row in result {
            budgets.append(try Budget.parse(row))
        }
        return budgets
    }
    
    // MARK: - Budget
    
    func GetBudget(_ id: Int64) throws -> Budget? {
        let query = Budget.table.filter(Budget.id == id)
        let result = try SQL.getDriver().prepare(query)
        for row in result {
            return try queryBudget(try Budget.parse(row))
        }
        return nil
    }
    
    func GetLastBudget() throws -> Budget? {
        let query = Budget.table.limit(1).order(Budget.id.desc)
        let result = try SQL.getDriver().prepare(query)
        for row in result {
            return try queryBudget(try Budget.parse(row))
        }
        return nil
    }
    
    func GetLastBudgetID() throws -> Int64? {
        let query = Budget.table.limit(1).order(Budget.id.desc).select(Budget.id)
        let result = try SQL.getDriver().prepare(query)
        for row in result {
            return try row.get(Budget.id)
        }
        return nil
    }
    
    func CreateBudget(_ b: Budget) throws -> Int64 {
        let insert = Budget.table.insert(
            Budget.startAt <- b.startAt,
            Budget.archiveAt <- b.archiveAt,
            Budget.amount <- b.amount,
            Budget.cost <- b.cost,
            Budget.balance <- b.balance,
            Budget.updatedAt <- b.updatedAt
        )
        
        return try SQL.getDriver().run(insert)
    }
    
    func UpdateBudget(_ b: Budget) throws {
        let update = Budget.table.filter(Budget.id == b.id).update(
            Budget.startAt <- b.startAt,
            Budget.archiveAt <- b.archiveAt,
            Budget.amount <- b.amount,
            Budget.cost <- b.cost,
            Budget.balance <- b.balance,
            Budget.updatedAt <- b.updatedAt
        )
        try SQL.getDriver().run(update)
    }
    
    func DeleteBudget(_ id: Int64) throws {
        try SQL.getDriver().run(Budget.table.filter(Budget.id == id).delete())
    }
    
    
    // MARK: - Card
    
    func GetCard(_ id: Int64) throws -> Card? {
        let query = Card.table.filter(Card.id == id)
        let result = try SQL.getDriver().prepare(query)
        for row in result {
            return try queryCard(try Card.parse(row))
        }
        return nil
    }
    
    func ListCards(_ budgetID: Int64) throws -> [Card] {
        let query = Card.table.filter(Card.budgetID == budgetID)
        let result = try SQL.getDriver().prepare(query)
        var cards: [Card] = []
        for row in result {
            cards.append(try queryCard(try Card.parse(row)))
        }
        return cards
    }
    
    func ListCards(_ chainID: UUID) throws -> [Card] {
        let query = Card.table.filter(Card.chainID == chainID)
        let result = try SQL.getDriver().prepare(query)
        var cards: [Card] = []
        for row in result {
            cards.append(try queryCard(try Card.parse(row)))
        }
        return cards
    }
    
    func ListCardsWithoutChildren(_ budgetID: Int64) throws -> [Card] {
        let query = Card.table.filter(Card.budgetID == budgetID)
        let result = try SQL.getDriver().prepare(query)
        var cards: [Card] = []
        for row in result {
            cards.append(try Card.parse(row))
        }
        return cards
    }
    
    func ListChainableCards() throws -> [Card] {
        let query = Card.table.select(Card.chainID).group(Card.chainID, having: Card.chainID.count > 1)
        let result = try SQL.getDriver().prepare(query)
        var ids: [UUID] = []
        for row in result {
            ids.append(try row.get(Card.chainID))
        }

        var cards: [Card] = []
        for id in ids {
            let query = Card.table.filter(Card.chainID == id).limit(1)
            let result = try SQL.getDriver().prepare(query)
            for row in result {
                cards.append(try Card.parse(row))
            }
        }
        cards.sort(by: { $0.id > $1.id })
        return cards
    }
    
    func ListChainableCards(_ budget: Budget) throws -> [Card] {
        let query = Card.table.select(Card.chainID).group(Card.chainID, having: Card.chainID.count > 1)
        let result = try SQL.getDriver().prepare(query)
        var ids: Set<UUID> = []
        for row in result {
            ids.insert(try row.get(Card.chainID))
        }
        
        return budget.book.filter({ ids.contains($0.chainID) })
    }
    
    func CreateCard(_ c: Card) throws -> Int64 {
        let insert = Card.table.insert(
            Card.chainID <- c.chainID,
            Card.budgetID <- c.budgetID,
            Card.index <- c.index,
            Card.name <- c.name,
            Card.amount <- c.amount,
            Card.cost <- c.cost,
            Card.balance <- c.balance,
            Card.display <- c.display,
            Card.fColor <- c.fColor,
            Card.bColor <- c.bColor,
            Card.gColor <- c.gColor,
            Card.pinned <- c.pinned,
            Card.updatedAt <- Date.now.unix
        )
        return try SQL.getDriver().run(insert)
    }
    
    func UpdateCard(_ c: Card) throws {
        let update = Card.table.filter(Card.id == c.id).update(
            Card.chainID <- c.chainID,
            Card.budgetID <- c.budgetID,
            Card.index <- c.index,
            Card.name <- c.name,
            Card.amount <- c.amount,
            Card.cost <- c.cost,
            Card.balance <- c.balance,
            Card.display <- c.display,
            Card.fColor <- c.fColor,
            Card.bColor <- c.bColor,
            Card.gColor <- c.gColor,
            Card.pinned <- c.pinned,
            Card.updatedAt <- Date.now.unix
        )
        try SQL.getDriver().run(update)
    }
    
    func DeleteCard(_ id: Int64) throws {
        try SQL.getDriver().run(Card.table.filter(Card.id == id).delete())
    }
    
    func DeleteCards(_ budgetID: Int64) throws {
        try SQL.getDriver().run(Card.table.filter(Card.budgetID == budgetID).delete())
    }
    
    // MARK: - Record
    
    func GetRecord(_ id: Int64) throws -> Record? {
        let result = try SQL.getDriver().query(Record.self) { $0.where(Record.id == id) }
        for row in result {
            return try Record.parse(row)
        }
        return nil
    }
    
    func ListRecords(after time: Date) throws -> [Record] {
        let result = try SQL.getDriver().query(Record.self) { $0.where(Record.updatedAt >= time.unix).order(Record.id.desc) }
        var records: [Record] = []
        for row in result {
            records.append(try Record.parse(row))
        }
        return records
    }
    
    func ListRecords(_ cardID: Int64) throws -> [Record] {
        let result = try SQL.getDriver().query(Record.self) { $0.where(Record.cardID == cardID).order(Record.id.desc) }
        var records: [Record] = []
        for row in result {
            records.append(try Record.parse(row))
        }
        return records
    }
    
    func CreateRecord(_ r: Record) throws -> Int64 {
        return try SQL.getDriver().insert(r)
    }
    
    func UpdateRecord(_ r: Record) throws {
        _ = try SQL.getDriver().update(r, where: Record.id == r.id)
    }
    
    func DeleteRecord(_ id: Int64) throws {
        try SQL.getDriver().run(Record.table.filter(Record.id == id).delete())
    }
    
    func DeleteRecords(_ cardID: Int64) throws {
        try SQL.getDriver().run(Record.table.filter(Record.cardID == cardID).delete())
    }
    
    // MARK: - Tag
    
    func IsTagExist(_ chainID: UUID, _ type: TagType, _ value: String) throws -> Bool {
        let query = Tag.table.filter(
            Tag.chainID == chainID &&
            Tag.type == type &&
            Tag.value == value
        ).exists
        return try SQL.getDriver().scalar(query)
    }
    
    func ListTags(_ chainID: UUID, _ type: TagType, _ time: Int, _ seconds: Int, _ count: Int) throws -> [Tag] {
        var tags: [Tag] = []
        var start = time - seconds
        var end = time + seconds
        
        #if DEBUG
        print("DAO list tags PARAM: type: \(type), start: \(start), end: \(end)")
        #endif
        
        let query = Tag.table.filter(
            Tag.chainID == chainID &&
            Tag.type == type &&
            Tag.key >= start &&
            Tag.key <= end &&
            Tag.count > 0
        ).order(Tag.count.desc).limit(count)
        let result = try SQL.getDriver().prepare(query)
        for row in result {
            tags.append(try Tag.parse(row))
        }
        
        let secondOfDay = SecondOfDay()
        
        if start < 0 {
            start += secondOfDay
            end += secondOfDay
        } else if end > secondOfDay {
            start -= secondOfDay
            end -= secondOfDay
        } else {
            return tags
        }
        
        let query2 = Tag.table.filter(
            Tag.chainID == chainID &&
            Tag.type == type &&
            Tag.key >= start &&
            Tag.key <= end &&
            Tag.count > 0
        ).order(Tag.count.desc).limit(count)
        let result2 = try SQL.getDriver().prepare(query2)
        for row in result2 {
            tags.append(try Tag.parse(row))
        }
        
        #if DEBUG
        print("DAO list tags RESULT: \(tags)")
        #endif
        return tags
    }
    
    func GetTag(_ chainID: UUID, _ type: TagType, _ value: String) throws -> Tag? {
        let query = Tag.table.filter(
            Tag.chainID == chainID &&
            Tag.type == type &&
            Tag.value == value
        )
        let result = try SQL.getDriver().prepare(query)
        for row in result {
            return try Tag.parse(row)
        }
        return nil
    }
    
    func CreateTag(_ t: Tag) throws -> Int64 {
        let insert = Tag.table.insert(
            Tag.chainID <- t.chainID,
            Tag.type <- t.type,
            Tag.value <- t.value,
            Tag.count <- t.count,
            Tag.key <- t.key,
            Tag.updatedAt <- Date.now.unix
        )
        return try SQL.getDriver().run(insert)
    }
    
    func UpdateTag(_ t: Tag) throws {
        let update = Tag.table.filter(Tag.id == t.id).update(
            Tag.chainID <- t.chainID,
            Tag.type <- t.type,
            Tag.value <- t.value,
            Tag.count <- t.count,
            Tag.key <- t.key,
            Tag.updatedAt <- Date.now.unix
        )
        try SQL.getDriver().run(update)
    }
    
    func DeleteTag(_ id: Int64) throws {
        try SQL.getDriver().run(Tag.table.filter(Tag.id == id).delete())
    }
    
    func DeleteTags(_ chainID: UUID) throws {
        try SQL.getDriver().run(Tag.table.filter(Tag.chainID == chainID).delete())
    }
    
    func DeleteTags(before time: Date) throws {
        let delete = Tag.table.filter(Tag.updatedAt <= time.unix).delete()
        try SQL.getDriver().run(delete)
    }
}

// MARK: - Private Function
fileprivate extension DataDao {
    
    private func SecondOfDay() -> Int { return 86400 }
    
    private func countBudget() throws -> Int {
        return try SQL.getDriver().scalar(Budget.table.count)
    }
    
    private func queryBudget(_ b: Budget) throws -> Budget {
        let query = Card.table.filter(Card.budgetID == b.id).order(Card.index.asc)
        let result = try SQL.getDriver().prepare(query)
        for row in result {
            let c = try queryCard(try Card.parse(row))
            b.book.append(c)
            if c.isForever { continue }
            b.amount += c.amount
            b.cost += c.cost
        }
        b.balance = b.amount - b.cost
        return b
    }
    
    private func queryCard(_ c: Card) throws -> Card {
        let query = Record.table.filter(Record.cardID == c.id).order(Record.date.desc)
        let result = try SQL.getDriver().prepare(query)
        for row in result {
            let r = try Record.parse(row)
            if r.pinned {
                c.AddRecordToFixed(r)
            } else {
                c.AddRecordToDict(r)
            }
            c.cost += r.cost
        }
        c.balance = c.amount - c.cost
        return c
    }
}
