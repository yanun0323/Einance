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
    func ListCards(_ chainID:UUID) throws -> [Card]
    func ListChainableCards() throws -> [Card]
    func ListChainableCards(_ budget: Budget) throws -> [Card]
    func CreateCard(_:Card) throws -> Int64
    func UpdateCard(_:Card) throws
    func DeleteCard(_:Int64) throws
    func DeleteCards(_ budgetID:Int64) throws
    
    func GetRecord(_:Int64) throws -> Record?
    func ListRecords(after:Date) throws -> [Record]
    func ListRecords(_ cardID:Int64) throws -> [Record]
    func CreateRecord(_:Record) throws -> Int64
    func UpdateRecord(_:Record) throws
    func DeleteRecord(_:Int64) throws
    func DeleteRecords(_ cardID:Int64) throws
    
    func IsTagExist(_:UUID, _:TagType, _:String) throws -> Bool
    func GetTag(_:UUID, _:TagType, _:String) throws -> Tag?
    func ListTags(_:UUID, _:TagType, _ time:Int, _ seconds:Int, _ count:Int) throws -> [Tag]
    func CreateTag(_:Tag) throws -> Int64
    func UpdateTag(_:Tag) throws
    func DeleteTag(_:Int64) throws
    func DeleteTags(_:UUID) throws
    func DeleteTags(before:Date) throws
}

protocol UserSettingRepository {
    func GetAppearance() -> Int?
    func SetAppearance(_:Int?)
    
    func GetBaseDateNumber() -> Int
    func SetBaseDateNumber(_:Int?)
    func GetFirstStartDate() -> Date
    
    func GetCardBudgetCategoryAbove() -> Int?
    func SetCardBudgetCategoryAbove(_:Int?)
    func GetCardBudgetCategoryBelow() -> Int?
    func SetCardBudgetCategoryBelow(_:Int?)
    
    func GetDashboardBudgetCategoryRight() -> Int?
    func SetDashboardBudgetCategoryRight(_:Int?)
    func GetDashboardBudgetCategoryLeft() -> Int?
    func SetDashboardBudgetCategoryLeft(_:Int?)
    
    func GetLastTimerCheckedDate() -> Date?
    func SetLastTimerCheckedDate(_ date: Date)
    
    func GetMockDBName() -> String
    func SetMockDBName(_:String)
    
    func GetLocale() -> Locale
    func SetLocale(_ :Locale)
    
    func GetPremium() -> Bool
    func SetPremium(_ value: Bool)
    
    func GetTutorialHomePage() -> Bool
    func SetTutorialHomePage(_ value: Bool)
    func GetTutorialCreateCard() -> Bool
    func SetTutorialCreateCard(_ value: Bool)
    func GetTutorialEditCard() -> Bool
    func SetTutorialEditCard(_ value: Bool)
    func GetTutorialCreateRecord() -> Bool
    func SetTutorialCreateRecord(_ value: Bool)
    func GetTutorialEditRecord() -> Bool
    func SetTutorialEditRecord(_ value: Bool)
    func GetTutorialSetting() -> Bool
    func SetTutorialSetting(_ value: Bool)
    
    func SetAllTutorial(_ value: Bool)
}