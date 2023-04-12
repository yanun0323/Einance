import SwiftUI
import UIComponent

struct Dashboard: View {
    @EnvironmentObject private var container: DIContainer
    @State private var leftCategory: BudgetCategory = .Amount
    @State private var rightCategory: BudgetCategory = .Cost
    
    @ObservedObject var budget: Budget
    @ObservedObject var current: Card
    var isPreview: Bool = false
    var previewColor: Color = .primary
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                if isPreview {
                    previewCategoryLabel($leftCategory)
                    Spacer()
                    previewCategoryLabel($rightCategory)
                } else {
                    categoryLabel(leftCategory)
                    Spacer()
                    categoryLabel(rightCategory)
                }
            }
            
            if isPreview || leftCategory == rightCategory || budget.amount.isZero {
                sameCategoryBarBlock()
            } else {
                barBlock()
                    .opacity(isPreview ? 0.5 : 1)
            }
            HStack {
                categoryValue(leftCategory)
                Spacer()
                categoryValue(rightCategory)
            }
            .opacity(isPreview ? 0.1 : 1)
        }
        .font(.system(size: 20, weight: .regular, design: .rounded))
        .kerning(isPreview ? 0 : 5)
        .monospacedDigit()
        .onAppear {
            leftCategory = container.interactor.setting.GetDashboardBudgetCategoryLeft()
            rightCategory = container.interactor.setting.GetDashboardBudgetCategoryRight()
        }
        .onChanged(of: leftCategory) { container.interactor.setting.SetDashboardBudgetCategoryLeft(leftCategory) }
        .onChanged(of: rightCategory) { container.interactor.setting.SetDashboardBudgetCategoryRight(rightCategory) }
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
    private func barBlock() -> some View {
        GeometryReader { bounds in
            HStack(spacing: 0) {
                if leftCategory == .Cost {
                    costBar(bounds)
                    Spacer()
                } else if rightCategory == .Cost {
                    Spacer()
                    costBar(bounds)
                } else if leftCategory == .Balance {
                    balanceBar(bounds)
                    Spacer()
                } else {
                    Spacer()
                    balanceBar(bounds)
                }
            }
        }
        .frame(height: 15)
        .backgroundColor(.section.opacity(0.5))
        .cornerRadius(5, antialiased: true)
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
    private func categoryLabel(_ c: BudgetCategory) -> some View {
        categoryText(c)
            .opacity(isHighlight(c) ? 1 : 0.5)
    }
    
    @ViewBuilder
    private func previewCategoryLabel(_ category: Binding<BudgetCategory>) -> some View {
        Menu {
            Picker("", selection: category) {
                ForEach(BudgetCategory.allCases) { value in
                    if value != .None {
                        Text(value.string).tag(value)
                    }
                }
            }
        } label: {
            Text(category.wrappedValue.string)
                .font(.system(size: 20, weight: .light))
                .foregroundColor(previewColor)
                .frame(width: 100, height: 20)
                .padding(5)
                .backgroundColor(.section.opacity(0.5))
                .cornerRadius(5)
        }
    }

    @ViewBuilder
    private func categoryText(_ category: BudgetCategory) -> some View {
        switch category {
            case .Amount:
                Text("label.amount")
            case .Balance:
                Text("label.balance")
            case .Cost:
                Text("label.cost")
            default:
                Text("label.cost")
        }
    }
    
    @ViewBuilder
    private func balanceBar(_ bounds: GeometryProxy) -> some View {
        HStack(spacing: 0) {
            ForEach(budget.book) { card in
                if !card.isForever {
                    Rectangle()
                        .frame(width: abs(card.balance/budget.amount).ToCGFloat()*bounds.size.width)
                        .foregroundColor(card.color)
                        .opacity(isCurrent(card.id) ? 1 : 0.25)
                }
            }
        }
    }
    
    @ViewBuilder
    private func costBar(_ bounds: GeometryProxy) -> some View {
        HStack(spacing: 0) {
            ForEach(budget.book) { card in
                if !card.isForever {
                    Rectangle()
                        .frame(width: (card.cost/budget.amount).ToCGFloat()*bounds.size.width)
                        .foregroundColor(card.color)
                        .opacity(isCurrent(card.id) ? 1 : 0.25)
                }
            }
        }
    }
    
    @ViewBuilder
    private func categoryValue(_ category: BudgetCategory) -> some View {
        Group {
            switch category {
                case .Amount:
                    Text(budget.amount.description)
                case .Balance:
                    Text(budget.balance.description)
                case .Cost:
                    Text(budget.cost.description)
                default:
                    Text(budget.cost.description)
            }
        }
        .opacity(isHighlight(category) ? 1 : 0.5)
    }
}

extension Dashboard {
    func isHighlight(_ ctg: BudgetCategory) -> Bool {
        if leftCategory == rightCategory { return true }
        if ctg == .Cost { return true }
        return ctg == .Balance && leftCategory != .Cost && rightCategory != .Cost
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
