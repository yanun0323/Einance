import SwiftUI

/**
 Budget category for viewing dashboard and card.
 
 Balance = 1, Amount = 2, Cost = 3
 */
enum BudgetCategory: Int, CaseIterable, Hashable {
    case None = 0, Balance = 1, Amount = 2, Cost = 3
}

extension BudgetCategory {
    init(_ number: Int?) {
        switch number {
        case 1:
            self = .Balance
        case 2:
            self = .Amount
        case 3:
            self = .Cost
        default:
            self = .None
        }
    }
    
    var string: LocalizedStringKey {
        switch self {
        case .Balance:
            return "label.balance"
        case .Amount:
            return "label.amount"
        case .Cost:
            return "label.cost"
        default:
            return ""
        }
    }
}

extension BudgetCategory: Identifiable {
    var id: Self { self }
}
