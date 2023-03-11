import SwiftUI
import UIComponent

struct StatisticView: View {
    @EnvironmentObject private var container: DIContainer
    @State private var selectedType: Int = 0
    @State private var height: CGFloat = 30
    @State private var width: CGFloat = 50
    
    @ObservedObject var budget: Budget
    @State var card: Card?
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                ViewHeader(title: "view.header.statistic")
                _TitleRowButton(proxy)
                Spacer()
            }
            .onAppear {
                width = proxy.size.width/3
            }
        }
        .padding(.horizontal, 30)
        .backgroundColor(.background)
        .transition(.scale(scale: 0.95, anchor: .topLeading).combined(with: .opacity))

    }
}

// MARK: - View Block
extension StatisticView {
    func _TitleRowButton(_ proxy: GeometryProxy) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: height*0.5)
                .foregroundColor(.background)
                .frame(width: width, height: height)
                .offset(x: CGFloat(selectedType)*width)
                .shadow(color: .section, radius: 3)
            HStack(spacing: 0) {
                _RowButton(0, "chart.pie.fill")
                _RowButton(1, "chart.bar.xaxis")
                _RowButton(2, "chart.line.uptrend.xyaxis")
            }
        }
        .padding(3)
        .background {
            RoundedRectangle(cornerRadius: height*0.6)
                .foregroundColor(.section)
        }
    }
    
    func _RowButton(_ index: Int, _ image: String) -> some View {
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

extension StatisticView {}

struct StatisticView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticView(budget: .preview)
            .inject(DIContainer.preview)
            .preferredColorScheme(.dark)
        StatisticView(budget: .preview)
            .inject(DIContainer.preview)
    }
}
