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
        let category = BudgetCategory(repo.GetCardBudgetCategoryAbove())
        if category != .None {
            return category
        }
        return .Cost
    }
    
    func SetCardBudgetCategoryAbove(_ category: BudgetCategory) {
        repo.SetCardBudgetCategoryAbove(category.rawValue)
        appstate.aboveBudgetCategoryPubliser.send(category)
    }
    
    func GetCardBudgetCategoryBelow() -> BudgetCategory {
        let category = BudgetCategory(repo.GetCardBudgetCategoryBelow())
        if category != .None {
            return category
        }
        return .Amount
    }
    
    func SetCardBudgetCategoryBelow(_ category: BudgetCategory) {
        repo.SetCardBudgetCategoryBelow(category.rawValue)
        appstate.belowBudgetCategoryPubliser.send(category)
    }
    
    func GetDashboardBudgetCategoryLeft() -> BudgetCategory {
        let category = BudgetCategory(repo.GetDashboardBudgetCategoryLeft())
        if category != .None {
            return category
        }
        return .Amount
    }
    
    func SetDashboardBudgetCategoryLeft(_ category: BudgetCategory) {
        repo.SetDashboardBudgetCategoryLeft(category.rawValue)
        appstate.leftBudgetCategoryPublisher.send(category)
    }
    
    func GetDashboardBudgetCategoryRight() -> BudgetCategory {
        let category = BudgetCategory(repo.GetDashboardBudgetCategoryRight())
        if category != .None {
            return category
        }
        return .Cost
    }
    
    func SetDashboardBudgetCategoryRight(_ category: BudgetCategory) {
        repo.SetDashboardBudgetCategoryRight(category.rawValue)
        appstate.rightBudgetCategoryPublisher.send(category)
    }
    
    func GetBaseDateNumber() -> Int {
        repo.GetBaseDateNumber()
    }
    
    func SetBaseDateNumber(_ n: Int) {
        repo.SetBaseDateNumber(n)
    }
    
    func IsExpired(_ start: Date) -> Bool {
        return Date.now >= Interactor.CalculateNextDate(start, days: repo.GetBaseDateNumber())
    }
    
    func GetMockDBName() -> String {
        return repo.GetMockDBName()
    }
    
    func SetMockDBName(_ name: String) {
        repo.SetMockDBName(name)
    }
    
    func GetLocale() -> Locale {
        return repo.GetLocale()
    }
    
    func SetLocale(_ l: Locale) {
        repo.SetLocale(l)
        appstate.localePublisher.send(l)
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
