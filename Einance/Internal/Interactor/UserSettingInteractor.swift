import SwiftUI

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
        return AppearanceToScheme(repo.GetAppearance())
    }
    
    func SetAppearance(_ scheme: ColorScheme?) {
        appstate.appearancePublisher.send(scheme)
        return repo.SetAppearance(SchemeToAppearance(scheme))
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
}

// MARK: - Helper
extension UserSettingInteractor {
    private func AppearanceToScheme(_ appearance: Int?) -> ColorScheme? {
        switch appearance {
        case 1:
            return .light
        case 2:
            return .dark
        default:
            return nil
        }
    }
    
    private func SchemeToAppearance(_ scheme: ColorScheme?) -> Int? {
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
