import SwiftUI

protocol Repository: DataRepository, UserSettingRepository {}

protocol DataRepository {
    func Tx<T>(_:() throws -> T?) throws -> T? where T: Any
    
    func GetBudgetCount() throws -> Int
    func ListBudgets() throws -> [Budget]
    func ListBudgetsWithoutChildren(_:Int64) throws -> [Budget]
    
    func IsDateBudgetArchived(_:Date) throws -> Bool
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
    
    func IsTagExist(_:UUID, _:TagType, _:String) throws -> Bool
    func ListTags(_:UUID, _:TagType, _ time:Int, _:TimeInterval, _ count:Int) throws -> [Tag]
    func GetTag(_:UUID, _:TagType, _:String) throws -> Tag?
    func CreateTag(_:Tag) throws -> Int64
    func UpdateTag(_:Tag) throws
    func DeleteTag(_:Int64) throws
    func DeleteTags(_:UUID) throws
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
