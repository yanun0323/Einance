import SwiftUI

protocol Repository: DataRepository, UserSettingRepository {}

protocol DataRepository {
    func GetBudgetCount() throws -> Int
    func GetBudgets() throws -> [Budget]
    func GetBudgetsWithoutChildren(_:Int64) throws -> [Budget]
    
    func GetBudget(_:Int64) throws -> Budget?
    func GetLastBudget() throws -> Budget?
    func GetBudgetWithoutChildren(_:Int64) throws -> Budget?
    func GetLastBudgetWithoutChildren() throws -> Budget?
    func CreateBudget(_:Budget) throws -> Int64
    func UpdateBudget(_:Budget) throws
    func DeleteBudget(_:Int64) throws
    
    func GetCard(_:Int64) throws -> Card?
    func GetCardWithoutChildren(_:Int64) throws -> Card?
    func GetCardCountOfBudget(_:Int64) throws -> Int?
    func CreateCard(_:Card) throws -> Int64
    func UpdateCard(_:Card) throws
    func DeleteCard(_:Int64) throws
    
    func GetRecord(_:Int64) throws -> Record?
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
