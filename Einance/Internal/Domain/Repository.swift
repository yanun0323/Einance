import SwiftUI

protocol Repository: DataRepository, UserSettingRepository {}

protocol DataRepository {
    func setup(_:String?, isMock:Bool, migrate:Bool)
    func trace(_:((String) -> Void)?)
    
    func Tx<T>(_:() throws -> T?) throws -> T? where T: Any
    
    func GetBudgetCount() throws -> Int
    func ListBudgets() throws -> [Budget]
    func ListBudgetsWithoutChildren() throws -> [Budget]
    
    func IsDateBudgetArchived(_:Date) throws -> Bool
    func GetBudget(_:Int64) throws -> Budget?
    func GetLastBudget() throws -> Budget?
    func GetLastBudgetID() throws -> Int64?
    func CreateBudget(_:Budget) throws -> Int64
    func UpdateBudget(_:Budget) throws
    func DeleteBudget(_:Int64) throws
    
    func GetCard(_:Int64) throws -> Card?
    func ListCards(_ budgetID:Int64) throws -> [Card]
    func ListCards(_ chainID:UUID) throws -> [Card]
    func ListCardsWithoutChildren(_ budgetID:Int64) throws -> [Card]
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
    func GetAppearance() throws -> Int?
    func SetAppearance(_:Int?) throws
    
    func GetBaseDateNumber() throws -> Int?
    func SetBaseDateNumber(_:Int?) throws
    
    func GetCardBudgetCategoryAbove() throws -> Int?
    func SetCardBudgetCategoryAbove(_:Int?) throws
    func GetCardBudgetCategoryBelow() throws -> Int?
    func SetCardBudgetCategoryBelow(_:Int?) throws
    
    func GetDashboardBudgetCategoryRight() throws -> Int?
    func SetDashboardBudgetCategoryRight(_:Int?) throws
    func GetDashboardBudgetCategoryLeft() throws -> Int?
    func SetDashboardBudgetCategoryLeft(_:Int?) throws
    
    func GetLastUpdateDateKey() throws -> String?
    func SetLastUpdateDateKey(_:String) throws
    
    func GetMockDBName() throws -> String?
    func SetMockDBName(_:String) throws
    
    func GetLocale() throws -> Locale?
    func SetLocale(_ :Locale) throws
    
    func GetPremium() throws -> Bool?
    func SetPremium(_:Bool) throws
    
    func GetTutorialHomePage() throws -> Bool?
    func SetTutorialHomePage(_:Bool) throws
    func GetTutorialCreateCard() throws -> Bool?
    func SetTutorialCreateCard(_:Bool) throws
    func GetTutorialEditCard() throws -> Bool?
    func SetTutorialEditCard(_:Bool) throws
    func GetTutorialCreateRecord() throws -> Bool?
    func SetTutorialCreateRecord(_:Bool) throws
    func GetTutorialEditRecord() throws -> Bool?
    func SetTutorialEditRecord(_:Bool) throws
    func GetTutorialSetting() throws -> Bool?
    func SetTutorialSetting(_:Bool) throws
    
    func SetAllTutorial(_:Bool) throws
}
