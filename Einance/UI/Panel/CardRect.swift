import SwiftUI
import UIComponent

struct CardRect: View {
    @EnvironmentObject private var container: DIContainer
    @State private var showAlert = false
    @State var card: Card
    @State var aboveCategory: BudgetCategory = .Cost
    @State var belowCategory: BudgetCategory = .Amount
    var isPreview: Bool = false

    var body: some View {
        GeometryReader { p in
            VStack(alignment: .trailing, spacing: size(p)*0.07) {
                HStack(alignment: .top, spacing: 0) {
                    Text(card.display.cardTag)
                        .font(.system(size: size(p)*0.05, weight: .light, design: .rounded))
                        .foregroundColor(cardTitleColor())
                    Spacer()
                    Text(card.name)
                        .font(.system(size: size(p)*0.11, weight: .medium, design: .rounded))
                        .foregroundColor(cardTitleColor())
                }
                .frame(height: size(p)*0.11)
                if isPreview {
                    VStack(alignment: .trailing, spacing: 5) {
                        PreviewAboveDecimalButton(p)
                        PreviewBelowDecimalButton(p)
                    }
                } else {
                    VStack(alignment: .trailing, spacing: -size(p)*0.02) {
                        AboveDecimalLabel(p)
                        BelowDecimalLabel(p)
                    }
                }
            }
            .monospacedDigit()
            .padding(.horizontal, size(p)*0.06)
            .frame(width: size(p), height: size(p)*0.66)
            .background(cardBackgroundColor())
            .cornerRadius(15)
            .contextMenu {
                ContextButtons
            }
            .alert("card.context.alert.title", isPresented: $showAlert, actions: { AlertButton }, message: {
                Text("card.context.alert.content")
            })
            .onAppear {
                aboveCategory = container.interactor.setting.GetCardBudgetCategoryAbove()
                belowCategory = container.interactor.setting.GetCardBudgetCategoryBelow()
            }
            .onChange(of: aboveCategory) { value in
                container.interactor.setting.SetCardBudgetCategoryAbove(value)
            }
            .onChange(of: belowCategory) { value in
                container.interactor.setting.SetCardBudgetCategoryBelow(value)
            }
            .onReceive(container.appstate.aboveBudgetCategoryPubliser) { output in
                if isPreview { return }
                aboveCategory = output
            }
            .onReceive(container.appstate.belowBudgetCategoryPubliser) { output in
                if isPreview { return }
                belowCategory = output
            }
        }
    }
}

// MARK: - View Block
extension CardRect {
    func AboveDecimalLabel(_ p: GeometryProxy) -> some View {
        Text(getCardMoney(aboveCategory).description)
            .font(.system(size: size(p)*0.13, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
    }
    
    func BelowDecimalLabel(_ p: GeometryProxy) -> some View {
        Text(getCardMoney(belowCategory).description)
            .font(.system(size: size(p)*0.13, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .opacity(0.3)
    }
    
    func PreviewAboveDecimalButton(_ p: GeometryProxy) -> some View {
        Menu {
            Picker("", selection: $aboveCategory) {
                ForEach(BudgetCategory.allCases) { category in
                    if category != .None {
                        Text(category.string).tag(category)
                    }
                }
            }
        } label: {
            Text(aboveCategory.string)
                .font(.system(size: size(p)*0.075, weight: .light))
                .foregroundColor(.blue)
                .frame(height: size(p)*0.1)
        }
        .frame(width: 120)
        .padding(5)
        .backgroundColor(.section)
        .cornerRadius(Setting.panelCornerRadius)
    }
    
    func PreviewBelowDecimalButton(_ p: GeometryProxy) -> some View {
        Menu {
            Picker("", selection: $belowCategory) {
                ForEach(BudgetCategory.allCases, id: \.self) { category in
                    if category != .None {
                        Text(category.string).tag(category)
                    }
                }
            }
        } label: {
            Text(belowCategory.string)
                .font(.system(size: size(p)*0.075, weight: .light))
                .foregroundColor(.blue)
                .frame(height: size(p)*0.1)
        }
        .frame(width: 120)
        .padding(5)
        .backgroundColor(.section)
        .cornerRadius(Setting.panelCornerRadius)
    }
    
    var ContextButtons: some View {
        VStack {
            Button {
                container.interactor.system.PushActionView(EditCardPanel(card: card))
            } label: {
                Label("global.edit", systemImage: "square.and.pencil")
            }
            
            Button(role: .destructive) {
                withAnimation {
                    showAlert = true
                }
            } label: {
                Label("global.delete", systemImage: "trash")
            }
        }
    }
    
    var AlertButton: some View {
        Button(role: .destructive) {
            withAnimation {
                print("card deleted")
            }
        } label: {
            Text("global.delete")
        }
    }
}

// MARK: - Function
extension CardRect {
    func size(_ proxy: GeometryProxy) -> CGFloat {
        return proxy.size.width
    }
    
    func cardBackgroundColor() -> Color {
        if isPreview {
            return .section
        }
        return card.color
    }
    
    func cardTitleColor() -> Color {
        if isPreview {
            return .section
        }
        return .white
    }
    
    func getCardMoney(_ category: BudgetCategory) -> Decimal {
        switch category {
        case .Balance:
            return card.balance
        case .Amount:
            return card.amount
        case .Cost:
            return card.cost
        default:
            return -1
        }
    }
}

struct CardRect_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CardRect(card: .preview, isPreview: true)
                .frame(width: System.device.screen.width, height: System.device.screen.width*0.66)
                .padding()
                .inject(DIContainer.preview)
            CardRect(card: .preview)
                .frame(width: System.device.screen.width*1.3, height: System.device.screen.width*0.66*1.3)
                .padding()
                .inject(DIContainer.preview)
            CardRect(card: .preview2)
                .frame(width: System.device.screen.width, height: System.device.screen.width*0.66)
                .padding()
                .inject(DIContainer.preview)
        }
        .previewLayout(.sizeThatFits)
    }
}
