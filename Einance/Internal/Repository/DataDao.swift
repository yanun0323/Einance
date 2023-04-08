import SwiftUI
import UIComponent
import SQLite

class DataDaoCache {}

protocol DataDao {}

extension DataDao where Self: DataRepository {
    // MARK: - Common
    
    func Tx<T>(_ action: () throws -> T?) throws -> T? where T: Any {
        var result: T?
        try Sql.GetDriver().transaction {
            result = try action()
        }
        return result
    }
    
    
    // MARK: - Budgets
    
    func IsDateBudgetArchived(_ archivedAt: Date) throws -> Bool {
        let query = Budget.Table().filter(Budget.archiveAt == archivedAt).exists
        return try Sql.GetDriver().scalar(query)
    }

    
    func GetBudgetCount() throws -> Int {
        return try countBudget()
    }
    
    func ListBudgets() throws -> [Budget] {
        var budgets: [Budget] = []
        let result = try Sql.GetDriver().prepare(Budget.Table().order(Budget.id.desc))
        for row in result {
            let b = try queryBudget(try parseBudget(row))
            budgets.append(b)
        }
        return budgets
    }
    
    func ListBudgetsWithoutChildren(_:Int64) throws -> [Budget] {
        var budgets: [Budget] = []
        let result = try Sql.GetDriver().prepare(Budget.Table().order(Budget.id.desc))
        for row in result {
            budgets.append(try parseBudget(row))
        }
        return budgets
    }
    
    // MARK: - Budget
    
    func GetBudget(_ id: Int64) throws -> Budget? {
        let query = Budget.Table().filter(Budget.id == id)
        let result = try Sql.GetDriver().prepare(query)
        for row in result {
            return try queryBudget(try parseBudget(row))
        }
        return nil
    }
    
    func GetLastBudget() throws -> Budget? {
        let query = Budget.Table().limit(1).order(Budget.id.desc)
        let result = try Sql.GetDriver().prepare(query)
        for row in result {
            return try queryBudget(try parseBudget(row))
        }
        return nil
    }
    
    func CreateBudget(_ b: Budget) throws -> Int64 {
        let insert = Budget.Table().insert(
            Budget.startAt <- b.startAt,
            Budget.archiveAt <- b.archiveAt,
            Budget.amount <- b.amount,
            Budget.cost <- b.cost,
            Budget.balance <- b.balance,
            Budget.updatedAt <- .now
        )
        
        return try Sql.GetDriver().run(insert)
    }
    
    func UpdateBudget(_ b: Budget) throws {
        let update = Budget.Table().filter(Budget.id == b.id).update(
            Budget.startAt <- b.startAt,
            Budget.archiveAt <- b.archiveAt,
            Budget.amount <- b.amount,
            Budget.cost <- b.cost,
            Budget.balance <- b.balance,
            Budget.updatedAt <- .now
        )
        try Sql.GetDriver().run(update)
    }
    
    func DeleteBudget(_ id: Int64) throws {
        try Sql.GetDriver().run(Budget.Table().filter(Budget.id == id).delete())
    }
    
    
    // MARK: - Card
    
    func GetCard(_ id: Int64) throws -> Card? {
        let query = Card.Table().filter(Card.id == id)
        let result = try Sql.GetDriver().prepare(query)
        for row in result {
            return try queryCard(try parseCard(row))
        }
        return nil
    }
    
    func ListCards(_ budgetID:Int64) throws -> [Card] {
        let query = Card.Table().filter(Card.budgetID == budgetID)
        let result = try Sql.GetDriver().prepare(query)
        var cards: [Card] = []
        for row in result {
            cards.append(try queryCard(try parseCard(row)))
        }
        return cards
    }
    
    func CreateCard(_ c: Card) throws -> Int64 {
        let insert = Card.Table().insert(
            Card.chainID <- c.chainID,
            Card.budgetID <- c.budgetID,
            Card.index <- c.index,
            Card.name <- c.name,
            Card.amount <- c.amount,
            Card.cost <- c.cost,
            Card.balance <- c.balance,
            Card.display <- c.display,
            Card.fontColor <- c.fontColor,
            Card.color <- c.color,
            Card.fixed <- c.fixed,
            Card.updatedAt <- .now
        )
        return try Sql.GetDriver().run(insert)
    }
    
    func UpdateCard(_ c: Card) throws {
        let update = Card.Table().filter(Card.id == c.id).update(
            Card.chainID <- c.chainID,
            Card.budgetID <- c.budgetID,
            Card.index <- c.index,
            Card.name <- c.name,
            Card.amount <- c.amount,
            Card.cost <- c.cost,
            Card.balance <- c.balance,
            Card.display <- c.display,
            Card.fontColor <- c.fontColor,
            Card.color <- c.color,
            Card.fixed <- c.fixed,
            Card.updatedAt <- .now
        )
        try Sql.GetDriver().run(update)
    }
    
    func DeleteCard(_ id: Int64) throws {
        try Sql.GetDriver().run(Card.Table().filter(Card.id == id).delete())
    }
    
    func DeleteCards(_ budgetID: Int64) throws {
        try Sql.GetDriver().run(Card.Table().filter(Card.budgetID == budgetID).delete())
    }
    
    // MARK: - Record
    
    func GetRecord(_ id: Int64) throws -> Record? {
        let query = Record.Table().filter(Record.id == id)
        let result = try Sql.GetDriver().prepare(query)
        for row in result {
            return try parseRecord(row)
        }
        return nil
    }
    
    func ListRecords(after time: Date) throws -> [Record] {
        let query = Record.Table().filter(Tag.updatedAt >= time)
        let result = try Sql.GetDriver().prepare(query)
        
        var records: [Record] = []
        for row in result {
            records.append(try parseRecord(row))
        }
        return records
    }
    
    func CreateRecord(_ r: Record) throws -> Int64 {
        let insert = Record.Table().insert(
            Record.cardID <- r.cardID,
            Record.date <- r.date,
            Record.cost <- r.cost,
            Record.memo <- r.memo,
            Record.fixed <- r.fixed,
            Record.updatedAt <- .now
        )
        return try Sql.GetDriver().run(insert)
    }
    
    func UpdateRecord(_ r: Record) throws {
        let update = Record.Table().filter(Record.id == r.id).update(
            Record.cardID <- r.cardID,
            Record.date <- r.date,
            Record.cost <- r.cost,
            Record.memo <- r.memo,
            Record.fixed <- r.fixed,
            Record.updatedAt <- .now
        )
        try Sql.GetDriver().run(update)
    }
    
    func DeleteRecord(_ id: Int64) throws {
        try Sql.GetDriver().run(Record.Table().filter(Record.id == id).delete())
    }
    
    func DeleteRecords(_ cardID: Int64) throws {
        try Sql.GetDriver().run(Record.Table().filter(Record.cardID == cardID).delete())
    }
    
    // MARK: - Tag
    
    func IsTagExist(_ chainID: UUID, _ type: TagType, _ value: String) throws -> Bool {
        let query = Tag.Table().filter(
            Tag.chainID == chainID &&
            Tag.type == type &&
            Tag.value == value
        ).exists
        return try Sql.GetDriver().scalar(query)
    }
    
    func ListTags(_ chainID: UUID, _ type: TagType, _ time: Int, _ interval: TimeInterval, _ count: Int) throws -> [Tag] {
        var tags: [Tag] = []
        let now = Date.now
        let start = now.addingTimeInterval(-interval).in24H
        let end = now.addingTimeInterval(interval).in24H
        #if DEBUG
        print("DAO list tags")
        #endif
        
        let query = Tag.Table().filter(
            Tag.chainID == chainID &&
            Tag.type == type &&
            Tag.key >= start &&
            Tag.key <= end &&
            Tag.count > 0
        ).order(Tag.count.desc).limit(count)
        let result = try Sql.GetDriver().prepare(query)
        for row in result {
            tags.append(try parseTag(row))
        }
        return tags
    }
    
    func GetTag(_ chainID: UUID, _ type: TagType, _ value: String) throws -> Tag? {
        let query = Tag.Table().filter(
            Tag.chainID == chainID &&
            Tag.type == type &&
            Tag.value == value
        )
        let result = try Sql.GetDriver().prepare(query)
        for row in result {
            return try parseTag(row)
        }
        return nil
    }
    
    func CreateTag(_ t: Tag) throws -> Int64 {
        let insert = Tag.Table().insert(
            Tag.chainID <- t.chainID,
            Tag.type <- t.type,
            Tag.value <- t.value,
            Tag.count <- t.count,
            Tag.key <- t.key,
            Tag.updatedAt <- .now
        )
        return try Sql.GetDriver().run(insert)
    }
    
    func UpdateTag(_ t: Tag) throws {
        let update = Tag.Table().filter(Tag.id == t.id).update(
            Tag.chainID <- t.chainID,
            Tag.type <- t.type,
            Tag.value <- t.value,
            Tag.count <- t.count,
            Tag.key <- t.key,
            Tag.updatedAt <- .now
        )
        try Sql.GetDriver().run(update)
    }
    
    func DeleteTag(_ id: Int64) throws {
        try Sql.GetDriver().run(Tag.Table().filter(Tag.id == id).delete())
    }
    
    func DeleteTags(_ chainID: UUID) throws {
        try Sql.GetDriver().run(Tag.Table().filter(Tag.chainID == chainID).delete())
    }
    
    func DeleteTags(before time: Date) throws {
        let delete = Tag.Table().filter(Tag.updatedAt <= time).delete()
        try Sql.GetDriver().run(delete)
    }
}

// MARK: - Private Function
extension DataDao {
    
    private func countBudget() throws -> Int {
        return try Sql.GetDriver().scalar(Budget.Table().count)
    }
    
    private func queryBudget(_ b: Budget) throws -> Budget {
        let query = Card.Table().filter(Card.budgetID == b.id).order(Card.index.asc)
        let result = try Sql.GetDriver().prepare(query)
        for row in result {
            let c = try queryCard(try parseCard(row))
            b.book.append(c)
            if c.isForever { continue }
            b.amount += c.amount
            b.cost += c.cost
        }
        b.balance = b.amount - b.cost
        return b
    }
    
    private func queryCard(_ c: Card) throws -> Card {
        let query = Record.Table().filter(Record.cardID == c.id).order(Record.date.desc)
        let result = try Sql.GetDriver().prepare(query)
        for row in result {
            let r = try parseRecord(row)
            if r.fixed {
                c.AddRecordToFixed(r)
            } else {
                c.AddRecordToDict(r)
            }
            c.cost += r.cost
        }
        c.balance = c.amount - c.cost
        return c
    }
    
    private func parseBudget(_ row: Row) throws -> Budget {
        return Budget(
            id: try row.get(Budget.id),
            startAt: try row.get(Budget.startAt),
            archiveAt: try row.get(Budget.archiveAt)
        )
    }
    
    private func parseCard(_ row: Row) throws -> Card {
        return Card(
            id: try row.get(Card.id),
            chainID: try row.get(Card.chainID),
            budgetID: try row.get(Card.budgetID),
            index: try row.get(Card.index),
            name: try row.get(Card.name),
            amount: try row.get(Card.amount),
            display: try row.get(Card.display),
            fontColor: try row.get(Card.fontColor),
            color: try row.get(Card.color),
            fixed: try row.get(Card.fixed)
        )
    }
    
    private func parseRecord(_ row: Row) throws -> Record {
        return Record(
            id: try row.get(Record.id),
            cardID: try row.get(Record.cardID),
            date: try row.get(Record.date),
            cost: try row.get(Record.cost),
            memo: try row.get(Record.memo),
            fixed: try row.get(Record.fixed)
        )
    }
    
    private func parseTag(_ row: Row) throws -> Tag {
        return Tag(
            id: try row.get(Tag.id),
            chainID: try row.get(Tag.chainID),
            type: try row.get(Tag.type),
            value: try row.get(Tag.value),
            count: try row.get(Tag.count),
            key: try row.get(Tag.key)
        )
    }
}
