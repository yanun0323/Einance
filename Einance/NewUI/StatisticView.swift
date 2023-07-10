import Charts
import Ditto
import SwiftUI

struct StatisticView: View {
    @Environment(\.injected) private var container: DIContainer
    @ObservedObject var budget: Budget

    var body: some View {
        StatisticPage(injecter: container, budget: budget)
            .navigationTitle("view.header.statistic")
            .transition(.scale(scale: 0.95, anchor: .top).combined(with: .opacity))
            .padding(.horizontal, 30)
            .background(Color.background)
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
