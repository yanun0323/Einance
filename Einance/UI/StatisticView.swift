import SwiftUI
import UIComponent

struct StatisticView: View {
    @EnvironmentObject private var container: DIContainer
    @State private var selectedType: Int = 0
    @State private var height: CGFloat = 30
    @State private var width: CGFloat = 50
    @State private var budgets: [Budget] = []
    
    @ObservedObject var budget: Budget
    @State var card: Card? = nil
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                ViewHeader(title: "view.header.statistic")
                viewCategoryRowButtons(proxy)
                    .transition(.opacity)
                
                ForEach(budgets) { b in
                    HStack {
                        Text(b.id.description)
                            .frame(width: 50)
                        Text(b.startAt.String("yyyy.MM.dd"))
                            .frame(width: 100)
                        Text(b.archiveAt?.String("yyyy.MM.dd") ?? "-")
                            .frame(width: 100)
                    }
                }
                
                Spacer()
            }
            .onAppear { width = proxy.size.width/3 }
        }
        .backgroundColor(.background)
        .onAppeared { budgets = container.interactor.data.ListBudgets() }
        .transition(.scale(scale: 0.95, anchor: .topLeading).combined(with: .opacity))
    }
    
    @ViewBuilder
    private func viewCategoryRowButtons(_ proxy: GeometryProxy) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: height*0.5)
                .foregroundColor(.background)
                .frame(width: width, height: height)
                .offset(x: CGFloat(selectedType)*width)
                .shadow(color: .black.opacity(0.2), radius: 3)
            HStack(spacing: 0) {
                rowButton(0, "chart.pie.fill")
                rowButton(1, "chart.bar.xaxis")
                rowButton(2, "chart.line.uptrend.xyaxis")
            }
        }
        .padding(3)
        .background {
            RoundedRectangle(cornerRadius: height*0.6)
                .foregroundColor(.section)
        }
    }
    
    @ViewBuilder
    private func rowButton(_ index: Int, _ image: String) -> some View {
        ButtonCustom(width: width, height: height) {
            withAnimation(.quick) {
                selectedType = index
            }
        } content: {
            Image(systemName: image)
                .font(.title3)
                .foregroundColor(selectedType == index ? .primary.opacity(0.9) : .section)
        }
    }
}

#if DEBUG
struct StatisticView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticView(budget: .preview)
            .inject(DIContainer.preview)
            .preferredColorScheme(.dark)
        StatisticView(budget: .preview)
            .inject(DIContainer.preview)
    }
}
#endif
