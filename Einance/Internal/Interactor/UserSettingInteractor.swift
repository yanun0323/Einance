import SwiftUI
import Ditto

struct UserSettingInteractor {
    private var appstate: AppState
    private var repo: Repository
    private var common: CommonInteractor
    
    init(appstate: AppState, repo: Repository, common: CommonInteractor) {
        self.appstate = appstate
        self.repo = repo
        self.common = common
    }
}

// MARK: - Public
extension UserSettingInteractor {
    func GetFirstStartDate() -> Date {
        let days = GetBaseDateNumber()
        let prev =  Date.now.addMonth(-1)
        let prevDay1 = prev.firstDayOfMonth
        var result = prevDay1.addDay(days-1)
        if prevDay1.daysOfMonth < days {
            result = prevDay1.addMonth(1).addDay(-1)
        }
        
        if result <= prev {
            return result.addMonth(1)
        }
        return result
    }
    
    func GetAppearance() -> ColorScheme? {
        return System.doCatch("get appearance") {
            return appearanceToScheme(try repo.GetAppearance())
        }
    }
    
    func SetAppearance(_ scheme: ColorScheme?) {
        System.doCatch("set appearance") {
            appstate.appearancePublisher.send(scheme)
            try repo.SetAppearance(schemeToAppearance(scheme))
        }
    }
    
    func GetCardBudgetCategoryAbove() -> FinanceCategory {
        return System.doCatch("get card budget categroy above") {
            let category = FinanceCategory(try repo.GetCardBudgetCategoryAbove())
            if category != .none {
                return category
            }
            return .cost
        } ?? .cost
    }
    
    func SetLastUpdateDateKey(_ date: Date) {
        System.doCatch("set last update date key") {
            try repo.SetLastUpdateDateKey(date.string("yyyy.MM"))
        }
    }
    
    func GetLastUpdateDateKey() -> String? {
        System.doCatch("get last update date key") {
            return try repo.GetLastUpdateDateKey()
        }
    }
    
    func SetCardBudgetCategoryAbove(_ category: FinanceCategory) {
        System.doCatch("set card budget category above") {
            try repo.SetCardBudgetCategoryAbove(category.rawValue)
            appstate.aboveBudgetCategoryPubliser.send(category)
        }
    }
    
    func GetCardBudgetCategoryBelow() -> FinanceCategory {
        return System.doCatch("get card budget category below") {
            let category = FinanceCategory(try repo.GetCardBudgetCategoryBelow())
            if category != .none {
                return category
            }
            return .amount
        } ?? .amount
    }
    
    func SetCardBudgetCategoryBelow(_ category: FinanceCategory) {
        System.doCatch("set card budget category below") {
            try repo.SetCardBudgetCategoryBelow(category.rawValue)
            appstate.belowBudgetCategoryPubliser.send(category)
        }
    }
    
    func GetDashboardBudgetCategoryLeft() -> FinanceCategory {
        return System.doCatch("get dashboard budget category left") {
            let category = FinanceCategory(try repo.GetDashboardBudgetCategoryLeft())
            if category != .none {
                return category
            }
            return .amount
        } ?? .amount
    }
    
    func SetDashboardBudgetCategoryLeft(_ category: FinanceCategory) {
        System.doCatch("set dashboard budget category left") {
            try repo.SetDashboardBudgetCategoryLeft(category.rawValue)
            appstate.leftBudgetCategoryPublisher.send(category)
        }
    }
    
    func GetDashboardBudgetCategoryRight() -> FinanceCategory {
        return System.doCatch("get dashboard budget category right") {
            let category = FinanceCategory(try repo.GetDashboardBudgetCategoryRight())
            if category != .none {
                return category
            }
            return .cost
        } ?? .cost
    }
    
    func SetDashboardBudgetCategoryRight(_ category: FinanceCategory) {
        System.doCatch("set dashboard budget category right") {
            try repo.SetDashboardBudgetCategoryRight(category.rawValue)
            appstate.rightBudgetCategoryPublisher.send(category)
        }
    }
    
    func GetBaseDateNumber() -> Int {
        return System.doCatch("get base date number") {
            return try repo.GetBaseDateNumber()
        } ?? 5
    }
    
    func SetBaseDateNumber(_ n: Int) {
        System.doCatch("set base date number") {
            try repo.SetBaseDateNumber(n)
        }
    }
    
    func IsExpired(_ start: Date) -> Bool {
        return Date.now >= common.CalculateNextDate(start, days: GetBaseDateNumber())
    }
    
    func GetMockDBName() -> String {
        return System.doCatch("get mock db name") {
            return try repo.GetMockDBName()
        } ?? "development"
    }
    
    func SetMockDBName(_ name: String) {
        System.doCatch("set mock db name") {
            try repo.SetMockDBName(name)
        }
    }
    
    func GetLocale() -> Locale {
        return System.doCatch("get locale") {
            return try repo.GetLocale()
        } ?? .current
    }
    
    func SetLocale(_ l: Locale) {
        System.doCatch("set locale") {
            try repo.SetLocale(l)
            appstate.localePublisher.send(l)
        }
    }
    
    func SetAllTutorial(_ value: Bool) {
        System.doCatch("set all tutorial") {
            try repo.SetAllTutorial(value)
        }
    }
    
}

// MARK: - Helper
extension UserSettingInteractor {
    private func appearanceToScheme(_ appearance: Int?) -> ColorScheme? {
        switch appearance {
        case 1:
            return .light
        case 2:
            return .dark
        default:
            return nil
        }
    }
    
    private func schemeToAppearance(_ scheme: ColorScheme?) -> Int? {
        switch scheme {
        case .light:
            return 1
        case .dark:
            return 2
        default:
            return 0
        }
    }
}
