import SwiftUI
import UIComponent

struct UserSettingInteractor {
    private var appstate: AppState
    private var repo: Repository
    
    init(appstate: AppState, repo: Repository) {
        self.appstate = appstate
        self.repo = repo
    }
}

// MARK: - Public
extension UserSettingInteractor {
    func GetAppearance() -> ColorScheme? {
        return appearanceToScheme(repo.GetAppearance())
    }
    
    func SetAppearance(_ scheme: ColorScheme?) {
        appstate.appearancePublisher.send(scheme)
        return repo.SetAppearance(schemeToAppearance(scheme))
    }
    
    func GetCardBudgetCategoryAbove() -> BudgetCategory {
        let category = BudgetCategory(UserDefaults.cardBudgetCategoryAbove)
        if category != .None {
            return category
        }
        return .Cost
    }
    
    func SetCardBudgetCategoryAbove(_ category: BudgetCategory) {
        UserDefaults.cardBudgetCategoryAbove = category.rawValue
        appstate.aboveBudgetCategoryPubliser.send(category)
    }
    
    func GetCardBudgetCategoryBelow() -> BudgetCategory {
        let category = BudgetCategory(UserDefaults.cardBudgetCategoryBelow)
        if category != .None {
            return category
        }
        return .Amount
    }
    
    func SetCardBudgetCategoryBelow(_ category: BudgetCategory) {
        UserDefaults.cardBudgetCategoryBelow = category.rawValue
        appstate.belowBudgetCategoryPubliser.send(category)
    }
    
    func GetDashboardBudgetCategoryLeft() -> BudgetCategory {
        let category = BudgetCategory(UserDefaults.dashboardBudgetCategoryLeft)
        if category != .None {
            return category
        }
        return .Amount
    }
    
    func SetDashboardBudgetCategoryLeft(_ category: BudgetCategory) {
        UserDefaults.dashboardBudgetCategoryLeft = category.rawValue
        appstate.leftBudgetCategoryPublisher.send(category)
    }
    
    func GetDashboardBudgetCategoryRight() -> BudgetCategory {
        let category = BudgetCategory(UserDefaults.dashboardBudgetCategoryRight)
        if category != .None {
            return category
        }
        return .Cost
    }
    
    func SetDashboardBudgetCategoryRight(_ category: BudgetCategory) {
        UserDefaults.dashboardBudgetCategoryRight = category.rawValue
        appstate.rightBudgetCategoryPublisher.send(category)
    }
    
    func SetbaseDateNumber(_ n: Int) {
        UserDefaults.baseDateNumber = n
    }
    
    func IsExpired(_ budgetExpiredDate: Date) -> Bool {
        let now = Date.now
        let nextDate = baseNumberToNextDate(UserDefaults.baseDateNumber) ?? now.AddDay(1)
        return now >= budgetExpiredDate || now >= nextDate
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
    
    private func baseNumberToNextDate(_ baseNumber: Int?) -> Date? {
        guard let n = baseNumber else { return nil }
        let now = Date.now
        var date = now.firstDayOfMonth.AddDay(n-1)
        if now > date {
            date = date.AddMonth(1)
        }
        return date
    }
}
