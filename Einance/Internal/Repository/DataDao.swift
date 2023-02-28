import SwiftUI
import UIComponent

class DataDaoCache {
    static var currentCard: Card? = nil
    static var currentBudget: Budget? = nil
}

protocol DataDao {}

extension DataDao where Self: DataRepository {
    func GetCurrentCard() -> Card {
        if let card = DataDaoCache.currentCard {
            return card
        }
        return .preview
    }
    
    func GetCurrentBudget() -> Budget {
        if let budget = DataDaoCache.currentBudget {
            return budget
        }
        
        let request = BudgetMO.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "uuid", ascending: true)]
        do {
            let result = try DatabaseController.context.fetch(BudgetMO.fetchRequest())
            return result[0]
        } catch {
            print("get current budget err: \(error)")
        }
    }
    
    func GetBudget(_ start: Date) -> Budget {
        return .preview
    }
    
    func GetBudgets() -> [Budget] {
        return [.preview, .preview, .preview]
    }
    
    func CreateBudget(_ b: Budget) {
        
    }
    
    func UpdateBudget(_ b: Budget) {
        
    }
    
    func DeleteBudget(_ budgetID: UUID) {
        
    }
    
    
    func CreateCard(_ budgetID: UUID, _ card: Card) {
        
    }
    
    func UpdateCard(_ card: Card) {
        
    }
    
    func DeleteCard(_ budgetID: UUID, _ cardID: UUID) {
        
    }
    
    
    func CreateRecord(_ cardID: UUID, _ record: Record) {
        
    }
    
    func UpdateRecord(_ record: Record) {
        
    }
    
    func DeleteRecord(_ cardID: UUID, _ recordID: UUID) {
        
    }
}
