import SwiftUI
import Combine
import Ditto

struct AppState {
    private static var `default`: AppState? = nil
    
    var budgetPublisher: CurrentValueSubject<Budget?, Never> = .init(nil)
    var monthlyCheckPublisher: PassthroughSubject<Bool, Never> = .init()
    
    var contentViewV2Publisher: PassthroughSubject<Bool, Never> = .init()
    var routerViewPublisher: CurrentValueSubject<ViewRouter?, Never> = .init(nil)
    var actionViewPublisher: CurrentValueSubject<ActionRouter?, Never> = .init(nil)
    
    var pickerPublisher: PassthroughSubject<Bool, Never> = .init()
    var appearancePublisher: PassthroughSubject<ColorScheme?, Never> = .init()
    var localePublisher: PassthroughSubject<Locale, Never> = .init()
    
    var aboveBudgetCategoryPubliser: PassthroughSubject<FinanceCategory, Never> = .init()
    var belowBudgetCategoryPubliser: PassthroughSubject<FinanceCategory, Never> = .init()
    var leftBudgetCategoryPublisher: PassthroughSubject<FinanceCategory, Never> = .init()
    var rightBudgetCategoryPublisher: PassthroughSubject<FinanceCategory, Never> = .init()
       
#if os(iOS)
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
#endif
}

extension AppState {
    static func get() -> Self {
        if Self.default.isNil {
            Self.default = Self()
        }
        return Self.default!
    }
}

enum ViewRouter {
    case Setting(DIContainer, Budget, Card)
    case BookOrder(Budget)
    case Statistic(Budget)
    case Analysis
    case Debug(Budget)
}

enum ActionRouter {
    case CreateCard(Budget)
    case EditCard(Budget, Card)
    case CreateRecord(Budget, Card)
    case EditRecord(Budget, Card, Record)
}

