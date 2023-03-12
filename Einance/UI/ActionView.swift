import SwiftUI

struct ActionView: View {
    var budget: Budget
    var card: Card?
    var record: Record?
    var router: Router
    var body: some View {
        if router == .CreateCard {
            CreateCardPanel(budget: budget)
        } else if router == .EditCard && card != nil {
            EditCardPanel(budget: budget, card: card!)
        } else if router == .CreateRecord && card != nil {
            CreateRecordPanel(budget: budget, card: card!)
        } else if router == .EditRecord && card != nil  && record != nil {
            EditRecordPanel(budget: budget, card: card!, record: record!)
        } else {
            Text("nil parameter, router: \(router.hashValue)")
        }
    }
}

extension ActionView {
    enum Router: Equatable {
        case CreateCard
        case EditCard
        case CreateRecord
        case EditRecord
    }
}

struct ActionView_Previews: PreviewProvider {
    static var previews: some View {
        ActionView(budget: .preview, card: .preview, router: .EditCard)
    }
}
