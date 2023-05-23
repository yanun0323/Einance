import SwiftUI
import Combine

struct AppState {
    var budgetPublisher: PassthroughSubject<Budget?, Never> = .init()
    var monthlyCheckPublisher: PassthroughSubject<Bool, Never> = .init()
    
    var contentViewV2Publisher: PassthroughSubject<Bool, Never> = .init()
    var routerViewPublisher: CurrentValueSubject<ViewRouter, Never> = .init(.Empty)
    var actionViewPublisher: CurrentValueSubject<ActionRouter, Never> = .init(.Empty)
    
    var pickerPublisher: PassthroughSubject<Bool, Never> = .init()
    var appearancePublisher: PassthroughSubject<ColorScheme?, Never> = .init()
    var localePublisher: PassthroughSubject<Locale, Never> = .init()
    
    var aboveBudgetCategoryPubliser: PassthroughSubject<FinanceCategory, Never> = .init()
    var belowBudgetCategoryPubliser: PassthroughSubject<FinanceCategory, Never> = .init()
    var leftBudgetCategoryPublisher: PassthroughSubject<FinanceCategory, Never> = .init()
    var rightBudgetCategoryPublisher: PassthroughSubject<FinanceCategory, Never> = .init()
        
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
        case Analysis
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

