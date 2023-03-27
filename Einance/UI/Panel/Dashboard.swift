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
                    _PreviewCategoryLabel($leftCategory)
                    Spacer()
                    _PreviewCategoryLabel($rightCategory)
                } else {
                    _CategoryLabel(leftCategory)
                    Spacer()
                    _CategoryLabel(rightCategory)
                }
            }
            
            if isPreview || leftCategory == rightCategory || budget.amount.isZero {
                _SameCategoryBarBlock
            } else {
                _BarBlock
                    .opacity(isPreview ? 0.5 : 1)
            }
            HStack {
                _CategoryValue(leftCategory)
                Spacer()
                _CategoryValue(rightCategory)
            }
            .opacity(isPreview ? 0.1 : 1)
        }
        .font(.system(size: 20, weight: .regular, design: .rounded))
        .kerning(5)
        .monospacedDigit()
        .onAppear {
            leftCategory = container.interactor.setting.GetDashboardBudgetCategoryLeft()
            rightCategory = container.interactor.setting.GetDashboardBudgetCategoryRight()
        }
        .onChange(of: leftCategory) { _ in
            container.interactor.setting.SetDashboardBudgetCategoryLeft(leftCategory)
        }
        .onChange(of: rightCategory) { _ in
            container.interactor.setting.SetDashboardBudgetCategoryRight(rightCategory)
        }
        .onReceive(container.appstate.leftBudgetCategoryPublisher) { output in
            if isPreview { return }
            withAnimation(.quick) {
                leftCategory = output
            }
        }
        .onReceive(container.appstate.rightBudgetCategoryPublisher) { output in
            if isPreview { return }
            withAnimation(.quick) {
                rightCategory = output
            }
        }
    }
}

// MARK: - View Block
extension Dashboard {
    var _BarBlock: some View {
        GeometryReader { bounds in
            HStack(spacing: 0) {
                if leftCategory == .Cost {
                    _costBar(bounds)
                    Spacer()
                } else if rightCategory == .Cost {
                    Spacer()
                    _costBar(bounds)
                } else if leftCategory == .Balance {
                    _balanceBar(bounds)
                    Spacer()
                } else {
                    Spacer()
                    _balanceBar(bounds)
                }
            }
        }
        .frame(height: 15)
        .backgroundColor(.section.opacity(0.5))
        .cornerRadius(5, antialiased: true)
    }
    
    var _SameCategoryBarBlock: some View {
        Rectangle()
            .frame(height: 15)
            .foregroundColor(Color.section.opacity(0.5))
            .cornerRadius(5, antialiased: true)
    }
}

// MARK: - View Function
extension Dashboard {
    func _CategoryLabel(_ c: BudgetCategory) -> some View {
        _categoryText(c)
            .opacity(isHighlight(c) ? 1 : 0.5)
    }
    
    func _CategoryValue(_ c: BudgetCategory) -> some View {
        _categoryValue(c)
            .opacity(isHighlight(c) ? 1 : 0.5)
    }
    
    func _PreviewCategoryLabel(_ category: Binding<BudgetCategory>) -> some View {
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
                .frame(height: 20)
        }
        .frame(width: 80)
        .padding(5)
        .backgroundColor(.section)
        .cornerRadius(5)
    }

    // MARK: Private
    
    private func _categoryText(_ category: BudgetCategory) -> some View {
        switch category {
            case .Amount:
                return Text("label.amount")
            case .Balance:
                return Text("label.balance")
            case .Cost:
                return Text("label.cost")
            default:
                return Text("label.cost")
        }
    }
    
    private func _balanceBar(_ bounds: GeometryProxy) -> some View {
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
    
    private func _costBar(_ bounds: GeometryProxy) -> some View {
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
    
    private func _categoryValue(_ category: BudgetCategory) -> some View {
        switch category {
            case .Amount:
                return Text(budget.amount.description)
            case .Balance:
                return Text(budget.balance.description)
            case .Cost:
                return Text(budget.cost.description)
            default:
                return Text(budget.cost.description)
        }
    }
}

// MARK: - Function
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
