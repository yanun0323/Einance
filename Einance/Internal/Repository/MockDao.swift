import SwiftUI

struct MockDao: UserSettingDao {
    private var budget: Budget = .preview
    private var current: Card = .preview
}

extension MockDao: Repository {
    func GetBudget() -> Budget {
        return budget
    }
    
    func GetCurrentCard() -> Card {
        current.records = current.records.sorted(by: { $0.date > $1.date })
        return current
    }
    
    func GetCurrentBudget() -> Budget {
        return budget
    }
    
    func GetBudget(_: Date) -> Budget {
        return budget
    }
    
    func GetBudgets() -> [Budget] {
        return [budget, budget]
    }
    
    func CreateBudget(_: Budget) {}
    
    func UpdateBudget(_: Budget) {}
    
    func DeleteBudget(_ budgetID: UUID) {}
    
    func CreateCard(_ budgetID: UUID, _: Card) {}
    
    func UpdateCard(_: Card) {}
    
    func DeleteCard(_ budgetID: UUID, _ cardID: UUID) {}
    
    func CreateRecord(_ cardID: UUID, _: Record) {}
    
    func UpdateRecord(_: Record) {}
    
    func DeleteRecord(_ cardID: UUID, _ recordID: UUID) {}
}
