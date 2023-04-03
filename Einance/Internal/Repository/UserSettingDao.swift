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
    
    func GetBaseDateNumber() -> Int {
        return UserDefaults.baseDateNumber ?? 5
    }
    
    func SetBaseDateNumber(_ number: Int?) {
        UserDefaults.baseDateNumber = number
    }
    
    func GetFirstStartDate() -> Date {
        let days = GetBaseDateNumber()
        let prev =  Date.now.AddMonth(-1)
        let prevDay1 = prev.firstDayOfMonth
        var result = prevDay1.AddDay(days-1)
        if prevDay1.daysOfMonth < days {
            result = prevDay1.AddMonth(1).AddDay(-1)
        }
        
        if result <= prev {
            return result.AddMonth(1)
        }
        return result
    }
    
    func GetNextStartDate(_ start: Date) -> Date {
        let days = GetBaseDateNumber()
        let nextDay1 = start.AddMonth(1).firstDayOfMonth
        
        if nextDay1.daysOfMonth < days {
            return nextDay1.AddMonth(1).AddDay(-1)
        }
        return nextDay1.AddDay(days-1)
    }
    
    func IsExpired(_ start: Date) -> Bool {
        return Date.now >= GetNextStartDate(start)
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
    
    func GetLastTimerCheckedDate() -> Date? {
        return UserDefaults.lastTimerCheckedDate
    }
    
    func SetLastTimerCheckedDate(_ date: Date) {
        UserDefaults.lastTimerCheckedDate = date
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
    
    @UserDefault(key: "LastTimerCheckedDate")
    static var lastTimerCheckedDate: Date?
    
    @UserDefault(key: "MockDBName")
    static var mockDBName: String?
    
    /**
     User stored appearance
     
     0 : system
     
     1 : light
     
     2 : dark
     */
    @UserDefault(key: "Appearance")
    static var appearance: Int?
}
