import Ditto
import SwiftUI

struct Dashboard: View {
    @Environment(\.injected) private var container: DIContainer
    @State private var leftCategory: FinanceCategory = .amount
    @State private var rightCategory: FinanceCategory = .cost

    @ObservedObject var budget: Budget
    @ObservedObject var current: Card
    var isPreview: Bool = false
    var previewColor: Color = .primary
    var isV2: Bool = false

    var body: some View {
        VStack(spacing: 10) {
            labelLayout()
            barLayout()
        }
        .font(.system(size: 20, weight: .regular, design: .rounded))
        .kerning(isPreview || isV2 ? 0 : 5)
        .monospacedDigit()
        .onAppear {
            leftCategory = container.interactor.setting.GetDashboardBudgetCategoryLeft()
            rightCategory = container.interactor.setting.GetDashboardBudgetCategoryRight()
        }
        .onChanged(of: leftCategory) {
            container.interactor.setting.SetDashboardBudgetCategoryLeft(leftCategory)
        }
        .onChanged(of: rightCategory) {
            container.interactor.setting.SetDashboardBudgetCategoryRight(rightCategory)
        }
        .onReceived(container.appstate.leftBudgetCategoryPublisher) {
            if isPreview { return }
            leftCategory = $0
        }
        .onReceived(container.appstate.rightBudgetCategoryPublisher) {
            if isPreview { return }
            rightCategory = $0
        }
        .backgroundColor(.transparent)
    }

    @ViewBuilder
    private func labelLayout() -> some View {
        HStack {
            if isPreview {
                previewCategoryLabel($leftCategory)
                if !isV2 { Spacer() }
                previewCategoryLabel($rightCategory)
                if isV2 { Spacer() }
            } else {
                categoryValue(leftCategory)
                if !isV2 { Spacer() }
                categoryValue(rightCategory)
                if isV2 { Spacer() }
            }
        }
        .font(isV2 ? .system(size: 30, weight: .medium) : nil)
    }

    @ViewBuilder
    private func barLayout() -> some View {
        if isPreview || leftCategory == rightCategory || budget.amount.isZero {
            sameCategoryBarBlock()
        } else {
            barBlock()
                .opacity(isPreview ? 0.5 : 1)
        }
    }

    @ViewBuilder
    private func barBlock() -> some View {
        GeometryReader { bounds in
            HStack(spacing: 0) {
                if leftCategory == .cost {
                    bar(of: .cost, bounds)
                    Spacer()
                } else if rightCategory == .cost {
                    Spacer()
                    bar(of: .cost, bounds)
                } else if leftCategory == .balance {
                    bar(of: .balance, bounds)
                    Spacer()
                } else {
                    Spacer()
                    bar(of: .balance, bounds)
                }
            }
        }
        .frame(height: 15)
        .backgroundColor(.section.opacity(0.2))
        .cornerRadius(7.5, antialiased: true)
    }

    @ViewBuilder
    private func sameCategoryBarBlock() -> some View {
        Rectangle()
            .frame(height: 15)
            .foregroundColor(Color.section.opacity(0.5))
            .cornerRadius(5, antialiased: true)
    }
}

// MARK: - View Function
extension Dashboard {
    @ViewBuilder
    private func categoryLabel(_ c: FinanceCategory) -> some View {
        categoryText(c)
            .opacity(isHighlight(c) ? 1 : 0.5)
    }

    @ViewBuilder
    private func previewCategoryLabel(_ category: Binding<FinanceCategory>) -> some View {
        Menu {
            Picker("", selection: category) {
                ForEach(FinanceCategory.allCases) { value in
                    if value != .none {
                        Text(value.label()).tag(value)
                    }
                }
            }
        } label: {
            Text(category.wrappedValue.label())
                .font(.system(size: 20, weight: .light))
                .foregroundColor(previewColor)
                .frame(width: 100, height: 20)
                .padding(5)
                .backgroundColor(.section.opacity(0.5))
                .cornerRadius(5)
        }
    }

    @ViewBuilder
    private func categoryText(_ category: FinanceCategory) -> some View {
        switch category {
        case .amount:
            Text("label.amount")
        case .balance:
            Text("label.balance")
        case .cost:
            Text("label.cost")
        default:
            Text("label.cost")
        }
    }

    @ViewBuilder func bar(of type: FinanceCategory, _ bounds: GeometryProxy) -> some View {
        HStack(spacing: 0) {
            ForEach(budget.book) { card in
                if !card.isForever {
                    LinearGradient(
                        colors: card.bgColor, startPoint: .topLeading, endPoint: .trailing
                    )
                    .frame(width: (type.value(card) / budget.amount).cgfloat * bounds.size.width)
                    .opacity(isCurrent(card.id) ? 1 : 0.25)
                }
            }
        }
    }

    @ViewBuilder
    private func categoryValue(_ category: FinanceCategory) -> some View {
        Group {
            switch category {
            case .amount:
                Text(budget.amount.description)
            case .balance:
                Text(budget.balance.description)
            case .cost:
                Text(budget.cost.description)
            default:
                Text(budget.cost.description)
            }
        }
        .opacity(isHighlight(category) ? 1 : (isV2 ? 0.2 : 0.5))
        .foregroundLinearGradient(isV2 && isHighlight(category) ? current.bgColor : [])
    }
}

extension Dashboard {
    func isHighlight(_ ctg: FinanceCategory) -> Bool {
        if leftCategory == rightCategory { return true }
        if ctg == .cost { return true }
        return ctg == .balance && leftCategory != .cost && rightCategory != .cost
    }

    func isCurrent(_ id: Int64) -> Bool {
        return current.id == id
    }
}

#if DEBUG
    struct Dashboard_Previews: PreviewProvider {
        static var previews: some View {
            VStack {
                Dashboard(budget: .preview, current: .preview)
                    .inject(DIContainer.preview)
                Dashboard(budget: .preview, current: .preview, isPreview: true)
                    .inject(DIContainer.preview)
            }
        }
    }
#endif
