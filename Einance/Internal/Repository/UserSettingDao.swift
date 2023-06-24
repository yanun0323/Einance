import SwiftUI
import Ditto

protocol UserSettingDao {}

extension UserSettingDao where Self: UserSettingRepository {
    func GetAppearance() throws -> Int? {
        return UserDefaults.appearance
    }
    
    func SetAppearance(_ appearance: Int?) throws {
        UserDefaults.appearance = appearance
    }
    
    func GetBaseDateNumber() throws -> Int? {
        return UserDefaults.baseDateNumber
    }
    
    func SetBaseDateNumber(_ value: Int?) throws {
        UserDefaults.baseDateNumber = value
    }
    
    func GetCardBudgetCategoryAbove() throws -> Int? {
        return UserDefaults.cardBudgetCategoryAbove
    }
    
    func SetCardBudgetCategoryAbove(_ value: Int?) throws {
        UserDefaults.cardBudgetCategoryAbove = value
    }
    
    func GetCardBudgetCategoryBelow() throws -> Int? {
        return UserDefaults.cardBudgetCategoryBelow
    }
    
    func SetCardBudgetCategoryBelow(_ value: Int?) throws {
        UserDefaults.cardBudgetCategoryBelow = value
    }
    
    func GetDashboardBudgetCategoryRight() throws -> Int? {
        return UserDefaults.dashboardBudgetCategoryRight
    }
    
    func SetDashboardBudgetCategoryRight(_ value: Int?) throws {
        UserDefaults.dashboardBudgetCategoryRight = value
    }
    
    func GetDashboardBudgetCategoryLeft() throws -> Int? {
    
        return UserDefaults.dashboardBudgetCategoryLeft
    }
    
    func SetDashboardBudgetCategoryLeft(_ value: Int?) throws {
        UserDefaults.dashboardBudgetCategoryLeft = value
    }
    
    func GetLastUpdateDateKey() throws -> String? {
        return UserDefaults.lastUpdateDateKey
    }
    
    func SetLastUpdateDateKey(_ value: String) throws {
        UserDefaults.lastUpdateDateKey = value
    }
    
    func GetMockDBName() throws -> String? {
        return UserDefaults.mockDBName
    }
    
    func SetMockDBName(_ name: String) throws {
        UserDefaults.mockDBName = name
    }
    
    func GetLocale() throws -> Locale? {
        return Locale(data: UserDefaults.locale)
    }
    
    func SetLocale(_ l: Locale) throws {
        UserDefaults.locale = l.int
    }
    
    func GetPremium() throws -> Bool? {
        return UserDefaults.premiumUser
    }
    
    func SetPremium(_ value: Bool) throws {
        UserDefaults.premiumUser =  value
    }
    
    func GetTutorialHomePage() throws -> Bool? {
        return UserDefaults.tutorialHomePage
    }
    
    func SetTutorialHomePage(_ value: Bool) throws {
        UserDefaults.tutorialHomePage = value
    }
    
    func GetTutorialCreateCard() throws -> Bool? {
        return UserDefaults.tutorialCreateCard
    }
    
    func SetTutorialCreateCard(_ value: Bool) throws {
        UserDefaults.tutorialCreateCard = value
    }
    
    func GetTutorialEditCard() throws -> Bool? {
        return UserDefaults.tutorialEditCard
    }
    
    func SetTutorialEditCard(_ value: Bool) throws {
        UserDefaults.tutorialEditCard = value
    }
    
    func GetTutorialCreateRecord() throws -> Bool? {
        return UserDefaults.tutorialCreateRecord
    }
    
    func SetTutorialCreateRecord(_ value: Bool) throws {
        UserDefaults.tutorialCreateRecord = value
    }
    
    func GetTutorialEditRecord() throws -> Bool? {
        return UserDefaults.tutorialEditRecord
    }
    
    func SetTutorialEditRecord(_ value: Bool) throws {
        UserDefaults.tutorialEditRecord = value
    }
    
    func GetTutorialSetting() throws -> Bool? {
        return UserDefaults.tutorialSetting
    }
    
    func SetTutorialSetting(_ value: Bool) throws {
        UserDefaults.tutorialSetting = value
    }
    
    func SetAllTutorial(_ value: Bool) throws {
        UserDefaults.tutorialCreateCard = value
        UserDefaults.tutorialEditCard = value
        UserDefaults.tutorialCreateRecord = value
        UserDefaults.tutorialEditRecord = value
        UserDefaults.tutorialHomePage = value
        UserDefaults.tutorialSetting = value
    }
    
//    func GetTutorial() throws -> Bool {
//        return UserDefaults.tutorial
//    }
//
//    func SetTutorial(_ value: Bool) throws {
//        UserDefaults.tutorial = value
//    }
    
}
extension Locale {
    public init(data: Int?) {
        switch data {
            case 1:
                self = .tw
            case 2:
                self = .us
            case 3:
                self = .jp
            default:
                self = .current
        }
    }
    
    public var int: Int {
        switch self {
            case .tw:
                return 1
            case .us:
                return 2
            case .jp:
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
