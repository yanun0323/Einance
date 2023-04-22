import SwiftUI

/**
 Budget category for viewing dashboard and card.
 
 Balance = 1, Amount = 2, Cost = 3
 */
enum FinanceCategory: Int, CaseIterable, Hashable {
    case none = 0, balance = 1, amount = 2, cost = 3
}

extension FinanceCategory {
    init(_ number: Int?) {
        switch number {
        case 1:
            self = .balance
        case 2:
            self = .amount
        case 3:
            self = .cost
        default:
            self = .none
        }
    }
    
    func label() -> LocalizedStringKey {
        switch self {
        case .balance:
            return "label.balance"
        case .amount:
            return "label.amount"
        case .cost:
            return "label.cost"
        default:
            return ""
        }
    }
    
    func value(_ c: Categoriable) -> Decimal {
        switch self {
            case .balance:
                return c.balance
            case .amount:
                return c.amount
            case .cost:
                return c.cost
            default:
                return 0
        }
    }
    
    func data(a: [Decimal], c: [Decimal], b: [Decimal]) -> [Decimal]? {
        switch self {
            case .amount:
                return a
            case .cost:
                return c
            case .balance:
                return b
            default:
                return nil
        }
    }
}

extension FinanceCategory: Identifiable {
    var id: Self { self }
}
