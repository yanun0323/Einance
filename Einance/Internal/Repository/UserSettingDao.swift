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
    
    func SetBaseDateNumber(_ value: Int?) {
        UserDefaults.baseDateNumber = value
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
    
    func GetCardBudgetCategoryAbove() -> Int? {
        return UserDefaults.cardBudgetCategoryAbove
    }
    
    func SetCardBudgetCategoryAbove(_ value: Int?) {
        UserDefaults.cardBudgetCategoryAbove = value
    }
    
    func GetCardBudgetCategoryBelow() -> Int? {
        return UserDefaults.cardBudgetCategoryBelow
    }
    
    func SetCardBudgetCategoryBelow(_ value: Int?) {
        UserDefaults.cardBudgetCategoryBelow = value
    }
    
    func GetDashboardBudgetCategoryRight() -> Int? {
        return UserDefaults.dashboardBudgetCategoryRight
    }
    
    func SetDashboardBudgetCategoryRight(_ value: Int?) {
        UserDefaults.dashboardBudgetCategoryRight = value
    }
    
    func GetDashboardBudgetCategoryLeft() -> Int? {
    
        return UserDefaults.dashboardBudgetCategoryLeft
    }
    
    func SetDashboardBudgetCategoryLeft(_ value: Int?) {
        UserDefaults.dashboardBudgetCategoryLeft = value
    }
    
    func GetLastUpdateDateKey() -> String? {
        return UserDefaults.lastUpdateDateKey
    }
    
    func SetLastUpdateDateKey(_ value: String) {
        UserDefaults.lastUpdateDateKey = value
    }
    
    func GetMockDBName() -> String {
        return UserDefaults.mockDBName ?? "development"
    }
    
    func SetMockDBName(_ name: String) {
        UserDefaults.mockDBName = name
    }
    
    func GetLocale() -> Locale {
        return Locale(data: UserDefaults.locale)
    }
    
    func SetLocale(_ l: Locale) {
        UserDefaults.locale = l.Int()
    }
    
    func GetPremium() -> Bool {
        return UserDefaults.premiumUser ?? false
    }
    
    func SetPremium(_ value: Bool) {
        UserDefaults.premiumUser =  value
    }
    
    func GetTutorialHomePage() -> Bool {
        return UserDefaults.tutorialHomePage ?? true
    }
    
    func SetTutorialHomePage(_ value: Bool) {
        UserDefaults.tutorialHomePage = value
    }
    
    func GetTutorialCreateCard() -> Bool {
        return UserDefaults.tutorialCreateCard ?? true
    }
    
    func SetTutorialCreateCard(_ value: Bool) {
        UserDefaults.tutorialCreateCard = value
    }
    
    func GetTutorialEditCard() -> Bool {
        return UserDefaults.tutorialEditCard ?? true
    }
    
    func SetTutorialEditCard(_ value: Bool) {
        UserDefaults.tutorialEditCard = value
    }
    
    func GetTutorialCreateRecord() -> Bool {
        return UserDefaults.tutorialCreateRecord ?? true
    }
    
    func SetTutorialCreateRecord(_ value: Bool) {
        UserDefaults.tutorialCreateRecord = value
    }
    
    func GetTutorialEditRecord() -> Bool {
        return UserDefaults.tutorialEditRecord ?? true
    }
    
    func SetTutorialEditRecord(_ value: Bool) {
        UserDefaults.tutorialEditRecord = value
    }
    
    func GetTutorialSetting() -> Bool {
        return UserDefaults.tutorialSetting ?? true
    }
    
    func SetTutorialSetting(_ value: Bool) {
        UserDefaults.tutorialSetting = value
    }
    
    func SetAllTutorial(_ value: Bool) {
        UserDefaults.tutorialCreateCard = value
        UserDefaults.tutorialEditCard = value
        UserDefaults.tutorialCreateRecord = value
        UserDefaults.tutorialEditRecord = value
        UserDefaults.tutorialHomePage = value
        UserDefaults.tutorialSetting = value
    }
    
//    func GetTutorial() -> Bool {
//        return UserDefaults.tutorial ?? true
//    }
//
//    func SetTutorial(_ value: Bool) {
//        UserDefaults.tutorial = value
//    }
    
}
extension Locale {
    public init(data: Int?) {
        switch data {
            case 1:
                self = .TW
            case 2:
                self = .US
            case 3:
                self = .JP
            default:
                self = .current
        }
    }
    
    public func Int() -> Int {
        switch self {
            case .TW:
                return 1
            case .US:
                return 2
            case .JP:
                return 3
            default:
                return 0
        }
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
    
    @UserDefault(key: "LastUpdateDateKey")
    static var lastUpdateDateKey: String?
    
    @UserDefault(key: "MockDBName")
    static var mockDBName: String?
    
    @UserDefault(key: "Locale")
    static var locale: Int?
    
    @UserDefault(key: "PremiumUser")
    static var premiumUser: Bool?
    
    @UserDefault(key: "TutorialHomePage")
    static var tutorialHomePage: Bool?
    
    @UserDefault(key: "TutorialCreateCard")
    static var tutorialCreateCard: Bool?
    
    @UserDefault(key: "TutorialEditCard")
    static var tutorialEditCard: Bool?
    
    @UserDefault(key: "TutorialCreateRecord")
    static var tutorialCreateRecord: Bool?
    
    @UserDefault(key: "TutorialEditRecord")
    static var tutorialEditRecord: Bool?
    
    @UserDefault(key: "TutorialSetting")
    static var tutorialSetting: Bool?
    
    /**
     User stored appearance
     
     0 : system
     
     1 : light
     
     2 : dark
     */
    @UserDefault(key: "Appearance")
    static var appearance: Int?
}
