import SwiftUI

protocol Repository: DataRepository, UserSettingRepository {}

protocol DataRepository {
    func GetCurrentBudget(_:Int) throws -> Budget
    func SetCurrentBudget(_:Budget) throws
    
    func GetBudget(_:Int64) throws -> Budget?
    func GetLastBudget() throws -> Budget?
    
    func GetBudgets() throws -> [Budget]
    
    func CreateBudget(_:Budget) throws -> Int64
    func UpdateBudget(_:Budget) throws
    func DeleteBudget(_:Int64) throws
    
    func CreateCard(_:Card) throws -> Int64
    func UpdateCard(_:Card) throws
    func DeleteCard(_:Int64) throws
    
    func CreateRecord(_:Record) throws -> Int64
    func UpdateRecord(_:Record) throws
    func DeleteRecord(_:Int64) throws
}

protocol UserSettingRepository {
    func GetAppearance() -> Int?
    func SetAppearance(_:Int?)
    
    func GetBaseDateNumber() -> Int?
    func SetBaseDateNumber(_ number: Int?)
    
    func GetCardBudgetCategoryAbove() -> Int?
    func SetCardBudgetCategoryAbove(_ category: Int?)
    func GetCardBudgetCategoryBelow() -> Int?
    func SetCardBudgetCategoryBelow(_ category: Int?)
}
