import SwiftUI
import Combine

struct AppState {
    var budgetPublisher: PassthroughSubject<Budget?, Never> = .init()
    var monthlyCheckPublisher: PassthroughSubject<Bool, Never> = .init()
    
    var routerViewPublisher: CurrentValueSubject<RouterView?, Never> = .init(nil)
    var actionViewPublisher: CurrentValueSubject<ActionView?, Never> = .init(nil)
    
    var pickerPublisher: PassthroughSubject<Bool, Never> = .init()
    var appearancePublisher: PassthroughSubject<ColorScheme?, Never> = .init()
    
    var aboveBudgetCategoryPubliser: PassthroughSubject<BudgetCategory, Never> = .init()
    var belowBudgetCategoryPubliser: PassthroughSubject<BudgetCategory, Never> = .init()
    var leftBudgetCategoryPublisher: PassthroughSubject<BudgetCategory, Never> = .init()
    var rightBudgetCategoryPublisher: PassthroughSubject<BudgetCategory, Never> = .init()
    
    var keyboardPublisher: AnyPublisher<Bool, Never> {
            Publishers.Merge(
                NotificationCenter.default
                    .publisher(for: UIResponder.keyboardWillShowNotification)
                    .map { _ in true },
                
                NotificationCenter.default
                    .publisher(for: UIResponder.keyboardWillHideNotification)
                    .map { _ in false }
            )
            .eraseToAnyPublisher()
        }
}
