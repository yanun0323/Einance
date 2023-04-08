import SwiftUI
import Combine

struct AppState {
    var budgetPublisher: PassthroughSubject<Budget?, Never> = .init()
    var monthlyCheckPublisher: PassthroughSubject<Bool, Never> = .init()
    
    var routerViewPublisher: CurrentValueSubject<ViewRouter, Never> = .init(.Empty)
    var actionViewPublisher: CurrentValueSubject<ActionRouter, Never> = .init(.Empty)
    
    var pickerPublisher: PassthroughSubject<Bool, Never> = .init()
    var appearancePublisher: PassthroughSubject<ColorScheme?, Never> = .init()
    var localePublisher: PassthroughSubject<Locale, Never> = .init()
    
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

extension AppState {
    enum ViewRouter {
        case Empty
        case Setting(DIContainer, Budget, Card)
        case BookOrder(Budget)
        case Statistic(Budget)
        case History
        case Debug(Budget)
        
        var isEmpty: Bool {
            switch self {
                case .Empty:
                    return true
                default:
                    return false
            }
        }
    }
}

extension AppState {
    enum ActionRouter {
        case Empty
        case CreateCard(Budget)
        case EditCard(Budget, Card)
        case CreateRecord(Budget, Card)
        case EditRecord(Budget, Card, Record)
        
        var isEmpty: Bool {
            switch self {
                case .Empty:
                    return true
                default:
                    return false
            }
        }
    }
}

