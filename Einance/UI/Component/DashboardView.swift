import SwiftUI
import Ditto

struct DashboardView: View {
    @Environment(\.injected) private var container
    @State private var main = FinanceCategory.amount
    @State private var secondary = FinanceCategory.cost
    
    @ObservedObject var budget: Budget
    @State var isSetting: Bool
    
    private let labelHeight = CGFloat(30)
    
    var body: some View {
        content()
            .frame(size: .dashboard)
            .onChange(of: main) { if isSetting { container.interactor.setting.SetDashboardBudgetCategoryLeft($0) }}
            .onChange(of: secondary) { if isSetting { container.interactor.setting.SetDashboardBudgetCategoryRight($0) }}
            .onReceive(container.appstate.leftBudgetCategoryPublisher) { if !isSetting { main = $0 }}
            .onReceive(container.appstate.rightBudgetCategoryPublisher) { if !isSetting { secondary = $0 }}
    }
    
    @ViewBuilder
    private func content() -> some View {
        VStack(spacing: 10) {
            if isSetting {
                labelView()
            } else {
                valueView()
            }
            barView()
        }
    }
    
    @ViewBuilder
    private func labelView() -> some View {
        HStack(spacing: 0) {
            label($main)
            Spacer()
            label($secondary)
        }
    }
    
    @ViewBuilder
    private func valueView() -> some View {
        HStack(spacing: 0) {
            value(main)
            Spacer()
            value(secondary)
        }
    }
    
    @ViewBuilder
    private func barView() -> some View {
        RoundedRectangle(cornerRadius: .barHeight)
            .frame(height: .barHeight)
            .foregroundColor(.section)
    }
    
    @ViewBuilder
    private func label(_ category: Binding<FinanceCategory>) -> some View {
        Menu {
            Picker(selection: category) {
                
            } label: {}
        } label: {
            Text(category.wrappedValue.label())
                .font(.system(.title))
                .padding(5)
        }
        .frame(height: labelHeight)
        .monospacedDigit()
        .debug()
    }
    
    @ViewBuilder
    private func value(_ category: FinanceCategory) -> some View {
        Text(category.value(budget).description)
            .font(.system(.title))
            .frame(height: labelHeight)
            .monospacedDigit()
            .padding(5)
            .debug()
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            DashboardView(budget: .preview, isSetting: true)
                .inject(.preview)
                .previewLayout(.sizeThatFits)
                .debug(cover: .dashboard)
                .frame(size: .dashboard)
            
            DashboardView(budget: .preview, isSetting: false)
                .inject(.preview)
                .previewLayout(.sizeThatFits)
                .debug(cover: .dashboard)
                .frame(size: .dashboard)
        }
    }
}
