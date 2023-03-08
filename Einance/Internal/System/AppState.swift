import SwiftUI
import Combine

struct AppState {
    var stopTheWorldPublisher: PassthroughSubject<Bool, Never> = .init()
    
    var budgetPublisher: PassthroughSubject<Budget?, Never> = .init()
    
    var routerViewPublisher: PassthroughSubject<AnyView?, Never> = .init()
    var actionViewPublisher: PassthroughSubject<AnyView?, Never> = .init()
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
