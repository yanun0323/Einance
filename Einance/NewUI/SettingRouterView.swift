import Ditto
import SwiftUI

struct SettingRouterView: View {
    @Environment(\.injected) private var container
    @State private var presented: Bool = true
    @ObservedObject var budget: Budget
    @ObservedObject var current: Card

    var body: some View {
        NavigationStack {
            #if DEBUG
            Button(width: 250, height: 50, colors: [.blue, .glue], radius: 15) {
                container.interactor.watch.sendMessage()
            } content: {
                Text("Send Message To Watch")
                    .foregroundColor(.white)
            }
            #endif

            List {
                targetView("view.header.setting") {
                    SettingViewV2(injector: container, budget: budget, current: current)
                }

                targetView("view.header.analysis") {
                    AnalysisView()
                }

                #if DEBUG
                    targetView("Debug") {
                        DebugView(budget: budget)
                    }
                #endif
            }
            .listStyle(.plain)
        }
    }

    @ViewBuilder
    private func targetView(_ title: LocalizedStringKey, target: @escaping () -> some View)
        -> some View
    {
        NavigationLink {
            target()
        } label: {
            Text(title)
        }
        .listRowSeparator(.hidden)
        .listSectionSeparator(.hidden)
        .frame(width: System.screen(.width, 0.9), alignment: .center)
    }
}

#if DEBUG
struct SettingRouterView_Previews: PreviewProvider {
    static var previews: some View {
        SettingRouterView(budget: .preview, current: .preview)
    }
}
#endif
