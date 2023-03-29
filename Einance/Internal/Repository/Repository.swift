import SwiftUI

protocol Repository: DataRepository, UserSettingRepository {}

protocol DataRepository {
    func Tx<T>(_:() throws -> T?) throws -> T? where T: Any
    
    func GetBudgetCount() throws -> Int
    func ListBudgets() throws -> [Budget]
    func ListBudgetsWithoutChildren(_:Int64) throws -> [Budget]
    
    func GetBudget(_:Int64) throws -> Budget?
    func GetLastBudget() throws -> Budget?
    func CreateBudget(_:Budget) throws -> Int64
    func UpdateBudget(_:Budget) throws
    func DeleteBudget(_:Int64) throws
    
    func GetCard(_:Int64) throws -> Card?
    func ListCards(_ budgetID:Int64) throws -> [Card]
    func CreateCard(_:Card) throws -> Int64
    func UpdateCard(_:Card) throws
    func DeleteCard(_:Int64) throws
    func DeleteCards(_ budgetID:Int64) throws
    
    func GetRecord(_:Int64) throws -> Record?
    func CreateRecord(_:Record) throws -> Int64
    func UpdateRecord(_:Record) throws
    func DeleteRecord(_:Int64) throws
    func DeleteRecords(_ cardID:Int64) throws
    
    // TODO: Tag
//    func GetTags(_:TagType, _:Int64, _:Int) throws -> [Tag]
//    func CreateTag(_:Tag) throws -> Int64
//    func UpdateTag(_:Tag) throws -> Int64
}

protocol UserSettingRepository {
    func GetAppearance() -> Int?
    func SetAppearance(_:Int?)
    
    func GetBaseDateNumber() -> Int
    func SetBaseDateNumber(_:Int?)
    func GetFirstStartDate() -> Date
    func GetNextStartDate(_:Date) -> Date
    func IsExpired(_:Date) -> Bool
    
    func GetCardBudgetCategoryAbove() -> Int?
    func SetCardBudgetCategoryAbove(_:Int?)
    func GetCardBudgetCategoryBelow() -> Int?
    func SetCardBudgetCategoryBelow(_:Int?)
}
