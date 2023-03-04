import SwiftUI

final class Current: ObservableObject {
    @Published var budget: Budget
    @Published var card: Card
    
    init(_ budget: Budget, _ card: Card) {
        self.budget = budget
        self.card = card
    }
}

extension Current {
    static var empty = Current(.empty, .empty)
}
