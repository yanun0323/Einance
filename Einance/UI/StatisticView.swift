import SwiftUI
import UIComponent
import Charts

struct StatisticView: View {
    @EnvironmentObject private var container: DIContainer
    @ObservedObject var budget: Budget
    
    var body: some View {
        VStack{
            ViewHeader(title: "view.header.statistic")
            StatisticPage(injecter: container, budget: budget)
        }
        .modifyRouterBackground()
        .transition(.scale(scale: 0.95, anchor: .top).combined(with: .opacity))
    }

}
#if DEBUG
struct StatisticView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticView(budget: .preview)
            .inject(DIContainer.preview)
            .preferredColorScheme(.dark)
    }
}
#endif
