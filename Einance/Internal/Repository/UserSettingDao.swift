import SwiftUI
import UIComponent

protocol UserSettingDao {}

extension UserSettingDao where Self: UserSettingRepository {
    func GetAppearance() -> Int? {
        return UserDefaults.appearance
    }
    
    func SetAppearance(_ appearance: Int?) {
        UserDefaults.appearance = appearance
    }
    
    func GetCardBudgetCategoryAbove() -> Int? {
        return UserDefaults.cardBudgetCategoryAbove
    }
    
    func SetCardBudgetCategoryAbove(_ category: Int?) {
        UserDefaults.cardBudgetCategoryAbove = category
    }
    
    func GetCardBudgetCategoryBelow() -> Int? {
        return UserDefaults.cardBudgetCategoryBelow
    }
    
    func SetCardBudgetCategoryBelow(_ category: Int?) {
        UserDefaults.cardBudgetCategoryBelow = category
    }
}

extension UserDefaults {
    @UserDefault(key: "BaseDateNumber")
    static var baseDateNumber: Int?
    
    @UserDefault(key: "DashboardBudgetCategoryLeft")
    static var dashboardBudgetCategoryLeft: Int?
    
    @UserDefault(key: "DashboardBudgetCategoryRight")
    static var dashboardBudgetCategoryRight: Int?
    
    @UserDefault(key: "CardBudgetCategoryAbove")
    static var cardBudgetCategoryAbove: Int?
    
    @UserDefault(key: "CardBudgetCategoryBelow")
    static var cardBudgetCategoryBelow: Int?
    
    
    /**
     User stored appearance
     
     0 : system
     
     1 : light
     
     2 : dark
     */
    @UserDefault(key: "Appearance")
    static var appearance: Int?
}
