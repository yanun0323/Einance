import SwiftUI

struct RouterView: View {
    @EnvironmentObject private var container: DIContainer
    var budget: Budget
    var current: Card?
    var router: Router
    
    var body: some View {
        if router == .Setting && current != nil {
            SettingView(injector: container, budget: budget, current: current!)
        } else if router == .BookOrder {
            BookOrderView(budget: budget)
        } else if router == .Statistic {
            StatisticView(budget: budget, card: current)
        } else if router == .Debug {
            DebugView(budget: budget)
        } else {
            Text("nil parameter, router: \(router.hashValue)")
        }
    }
}

extension RouterView {
    enum Router: Equatable {
        case Setting
        case BookOrder
        case Statistic
        case Debug
    }
}

struct RouterView_Previews: PreviewProvider {
    static var previews: some View {
        RouterView(budget: .preview, current: .preview, router: .Setting)
            .inject(DIContainer.preview)
    }
}
