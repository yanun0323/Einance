import SwiftUI

protocol Repository: DataRepository, UserSettingRepository {}

protocol DataRepository {
    func GetCurrentCard() -> Card
    
    func GetCurrentBudget() -> Budget
    func GetBudget(_:Date) -> Budget
    func GetBudgets() -> [Budget]
    
    func CreateBudget(_:Budget)
    func UpdateBudget(_:Budget)
    func DeleteBudget(_ budgetID: UUID)
    
    func CreateCard(_ budgetID: UUID, _:Card)
    func UpdateCard(_:Card)
    func DeleteCard(_ budgetID: UUID, _ cardID: UUID)
    
    func CreateRecord(_ cardID: UUID, _:Record)
    func UpdateRecord(_:Record)
    func DeleteRecord(_ cardID: UUID, _ recordID: UUID)
}

protocol UserSettingRepository {
    func GetAppearance() -> Int?
    func SetAppearance(_:Int?)
}
