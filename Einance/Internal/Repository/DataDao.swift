import SwiftUI
import UIComponent
import SQLite

class DataDaoCache {
    static var currentBudget: Budget? = nil
}

protocol DataDao {}

extension DataDao where Self: DataRepository {
    
    func GetCurrentBudget(_ day: Int) throws -> Budget {
        if let b = DataDaoCache.currentBudget {
            return b
        }
        
        if try countBudget() != 0, let b = try GetLastBudget() {
            DataDaoCache.currentBudget = b
            return b
        }
        
        let b = Budget(start: .now.firstDayOfMonth.AddDay(day-1))
        let id = try CreateBudget(b)
        b.id = id
        DataDaoCache.currentBudget = b
        return b
    }
    
    
    func SetCurrentBudget(_ b :Budget) {
        DataDaoCache.currentBudget = b
    }
    
    func GetLastBudget() throws -> Budget? {
        let query = Budget.GetTable().limit(1).order(Budget.id.desc)
        let result = try Sql.GetDriver().prepare(query)
        for row in result {
            return try queryBudget(try parseBudget(row))
        }
        return nil
    }
    
    func GetBudget(_ id: Int64) throws -> Budget? {
        let query = Budget.GetTable().filter(Budget.id == id)
        let result = try Sql.GetDriver().prepare(query)
        for row in result {
            return try queryBudget(try parseBudget(row))
        }
        return nil
    }
    
    func GetBudgets() throws -> [Budget] {
        var budgets: [Budget] = []
        let result = try Sql.GetDriver().prepare(Budget.GetTable().order(Budget.id.desc))
        for row in result {
            budgets.append(try queryBudget(try parseBudget(row)))
        }
        return budgets
    }
    
    func CreateBudget(_ b: Budget) throws -> Int64 {
        let insert = Budget.GetTable().insert(
            Budget.start <- b.start,
            Budget.amount <- b.amount,
            Budget.cost <- b.cost,
            Budget.balance <- b.balance
        )
        
        return try Sql.GetDriver().run(insert)
    }
    
    func UpdateBudget(_ b: Budget) throws {
        let update = Budget.GetTable().filter(Budget.id == b.id).update(
                Budget.start <- b.start,
                Budget.amount <- b.amount,
                Budget.cost <- b.cost,
                Budget.balance <- b.balance
            )
        try Sql.GetDriver().run(update)
    }
    
    func DeleteBudget(_ id: Int64) throws {
        try Sql.GetDriver().run(Budget.GetTable().filter(Budget.id == id).delete())
    }
    
    
    func CreateCard(_ c: Card) throws -> Int64 {
        print("[DEBUG] Card ID: \(c.id), Color: \(c.color), Color descripton: \(c.color.description)")
        let insert = Card.GetTable().insert(
            Card.budgetID <- c.budgetID,
            Card.index <- c.index,
            Card.name <- c.name,
            Card.amount <- c.amount,
            Card.cost <- c.cost,
            Card.balance <- c.balance,
            Card.display <- c.display,
            Card.color <- c.color,
            Card.fixed <- c.fixed
        )
        return try Sql.GetDriver().run(insert)
    }
    
    func UpdateCard(_ c: Card) throws {
        let update = Card.GetTable().filter(Card.id == c.id).update(
            Card.budgetID <- c.budgetID,
            Card.index <- c.index,
            Card.name <- c.name,
            Card.amount <- c.amount,
            Card.cost <- c.cost,
            Card.balance <- c.balance,
            Card.display <- c.display,
            Card.color <- c.color,
            Card.fixed <- c.fixed
        )
        try Sql.GetDriver().run(update)
    }
    
    func DeleteCard(_ id: Int64) throws {
        try Sql.GetDriver().run(Card.GetTable().filter(Card.id == id).delete())
    }
    
    
    func CreateRecord(_ r: Record) throws -> Int64 {
        let insert = Record.GetTable().insert(
            Record.cardID <- r.cardID,
            Record.date <- r.date,
            Record.cost <- r.cost,
            Record.memo <- r.memo,
            Record.fixed <- r.fixed
        )
        return try Sql.GetDriver().run(insert)
    }
    
    func UpdateRecord(_ r: Record) throws {
        let update = Record.GetTable().filter(Record.id == r.id).update(
            Record.cardID <- r.cardID,
            Record.date <- r.date,
            Record.cost <- r.cost,
            Record.memo <- r.memo,
            Record.fixed <- r.fixed
        )
        try Sql.GetDriver().run(update)
    }
    
    func DeleteRecord(_ id: Int64) throws {
        try Sql.GetDriver().run(Record.GetTable().filter(Record.id == id).delete())
    }
    
}

extension DataDao {
    
    private func countBudget() throws -> Int {
        return try Sql.GetDriver().scalar(Budget.GetTable().count)
    }
    
    private func queryBudget(_ b: Budget) throws -> Budget {
        let query = Card.GetTable().filter(Card.budgetID == b.id).order(Card.index.desc)
        let result = try Sql.GetDriver().prepare(query)
        for row in result {
            b.book.append(try queryCard(try parseCard(row)))
        }
        return b
    }
    
    private func queryCard(_ c: Card) throws -> Card {
        let query = Record.GetTable().filter(Record.cardID == c.id).order(Record.date.desc)
        let result = try Sql.GetDriver().prepare(query)
        for row in result {
            let r = try parseRecord(row)
            if c.dateDict[r.date.unixDay] == nil {
                c.dateDict[r.date.unixDay] = .init(records: [], cost: 0)
            }
            c.dateDict[r.date.unixDay]?.records.append(r)
            c.dateDict[r.date.unixDay]?.cost += r.cost
        }
        return c
    }
    
    private func parseBudget(_ row: Row) throws -> Budget {
        return Budget(
            id: try row.get(Budget.id),
            start: try row.get(Budget.start),
            amount: try row.get(Budget.amount),
            cost: try row.get(Budget.cost),
            balance: try row.get(Budget.balance)
        )
    }
    
    private func parseCard(_ row: Row) throws -> Card {
        return Card(
            id: try row.get(Card.id),
            budgetID: try row.get(Card.budgetID),
            index: try row.get(Card.index),
            name: try row.get(Card.name),
            amount: try row.get(Card.amount),
            cost: try row.get(Card.cost),
            balance: try row.get(Card.balance),
            display: try row.get(Card.display),
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
}
