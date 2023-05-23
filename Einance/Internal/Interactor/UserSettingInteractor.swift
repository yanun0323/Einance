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
    
    func GetCardBudgetCategoryAbove() -> FinanceCategory {
        let category = FinanceCategory(repo.GetCardBudgetCategoryAbove())
        if category != .none {
            return category
        }
        return .cost
    }
    
    func SetLastUpdateDateKey(_ date: Date) {
        repo.SetLastUpdateDateKey(date.String("yyyy.MM"))
    }
    
    func GetLastUpdateDateKey() -> String? {
        return repo.GetLastUpdateDateKey()
    }
    
    func SetCardBudgetCategoryAbove(_ category: FinanceCategory) {
        repo.SetCardBudgetCategoryAbove(category.rawValue)
        appstate.aboveBudgetCategoryPubliser.send(category)
    }
    
    func GetCardBudgetCategoryBelow() -> FinanceCategory {
        let category = FinanceCategory(repo.GetCardBudgetCategoryBelow())
        if category != .none {
            return category
        }
        return .amount
    }
    
    func SetCardBudgetCategoryBelow(_ category: FinanceCategory) {
        repo.SetCardBudgetCategoryBelow(category.rawValue)
        appstate.belowBudgetCategoryPubliser.send(category)
    }
    
    func GetDashboardBudgetCategoryLeft() -> FinanceCategory {
        let category = FinanceCategory(repo.GetDashboardBudgetCategoryLeft())
        if category != .none {
            return category
        }
        return .amount
    }
    
    func SetDashboardBudgetCategoryLeft(_ category: FinanceCategory) {
        repo.SetDashboardBudgetCategoryLeft(category.rawValue)
        appstate.leftBudgetCategoryPublisher.send(category)
    }
    
    func GetDashboardBudgetCategoryRight() -> FinanceCategory {
        let category = FinanceCategory(repo.GetDashboardBudgetCategoryRight())
        if category != .none {
            return category
        }
        return .cost
    }
    
    func SetDashboardBudgetCategoryRight(_ category: FinanceCategory) {
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
    
    func SetAllTutorial(_ value: Bool) {
        repo.SetAllTutorial(value)
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
