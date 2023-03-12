import SwiftUI
import UIComponent

struct CardRect: View {
    @EnvironmentObject private var container: DIContainer
    @State private var showDeleteAlert = false
    @State private var showArchiveAlert = false
    @State private var aboveCategory: BudgetCategory = .Cost
    @State private var belowCategory: BudgetCategory = .Amount
    
    @ObservedObject var budget: Budget
    @ObservedObject var card: Card
    var isPreview: Bool = false
    var previewColor: Color = .primary
    var isOrder: Bool = false

    var body: some View {
        GeometryReader { p in
            VStack(alignment: .trailing, spacing: size(p)*0.07) {
                _TitleBlock(p)
                
                if isPreview {
                    VStack(alignment: .trailing, spacing: 5) {
                        _PreviewCategoryLabel(p, $aboveCategory)
                        _PreviewCategoryLabel(p, $belowCategory)
                    }
                } else {
                    VStack(alignment: .trailing, spacing: -size(p)*0.02) {
                        _CategoryValue(p, aboveCategory, opacity: 1)
                        _CategoryValue(p, belowCategory, opacity: 0.3)
                    }
                }
            }
            .monospacedDigit()
            .padding(.horizontal, size(p)*0.06)
            .frame(width: size(p), height: size(p)*0.66)
            .background(cardBackgroundColor())
            .cornerRadius(15)
            .contextMenu {
                if !isPreview && !isOrder {
                    _ContextButtons
                }
            }
            .alert("card.context.alert.delete.title", isPresented: $showDeleteAlert, actions: {
                _AlertDeleteButton
            }, message: {
                Text("card.context.alert.delete.content")
            })
            .alert("card.context.alert.archive.title", isPresented: $showArchiveAlert, actions: {
                _AlertArchiveButton
            }, message: {
                Text("card.context.alert.archive.content")
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
    func _TitleBlock(_ p: GeometryProxy) -> some View {
        HStack(alignment: .top, spacing: 10) {
            if card.fixed {
                Image(systemName: "pin.fill")
                    .font(.system(size: size(p)*0.04, weight: .light, design: .rounded))
                    .foregroundColor(cardTitleColor())
                    .offset(y: size(p)*0.008)
                    .rotationEffect(Angle(degrees: 45))
            }
            #if DEBUG
            if isOrder {
                Text(card.index.description)
                    .font(.system(size: size(p)*0.05, weight: .light, design: .rounded))
                    .foregroundColor(cardTitleColor())
                    .opacity(5)
            }
            #endif
            Text(card.display.cardTag)
                .font(.system(size: size(p)*0.05, weight: .light, design: .rounded))
                .foregroundColor(cardTitleColor())
            Spacer()
            Text(card.name)
                .font(.system(size: size(p)*0.11, weight: .medium, design: .rounded))
                .foregroundColor(cardTitleColor())
        }
        .frame(height: size(p)*0.11)
    }
    
    func _CategoryValue(_ p: GeometryProxy, _ category: BudgetCategory, opacity: CGFloat) -> some View {
        Text(getCardMoney(category).description)
            .font(.system(size: size(p)*0.13, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .opacity(opacity)
    }
    
    func _PreviewCategoryLabel(_ p: GeometryProxy, _ category: Binding<BudgetCategory>) -> some View {
        Menu {
            Picker("", selection: category) {
                ForEach(BudgetCategory.allCases) { c in
                    if c != .None {
                        Text(c.string).tag(c)
                    }
                }
            }
        } label: {
            Text(category.wrappedValue.string)
                .font(.system(size: size(p)*0.075, weight: .light))
                .foregroundColor(previewColor)
                .frame(height: size(p)*0.1)
        }
        .frame(width: 120)
        .padding(5)
        .backgroundColor(.section)
        .cornerRadius(Setting.panelCornerRadius)
    }
    
    var _ContextButtons: some View {
        VStack {
            Button {
                container.interactor.system.PushActionView(ActionView(budget: budget, card: card, router: .EditCard))
            } label: {
                Label("global.edit", systemImage: "square.and.pencil")
            }
            
            if card.isForever {
                Button(role: .cancel) {
                    withAnimation(.quick) {
                        showArchiveAlert = true
                    }
                } label: {
                    Label("global.archive", systemImage: "archivebox")
                }
            }
            
            Button(role: .destructive) {
                withAnimation(.quick) {
                    showDeleteAlert = true
                }
            } label: {
                Label("global.delete", systemImage: "trash")
            }
        }
    }
    
    var _AlertDeleteButton: some View {
        Button("global.delete", role: .destructive) {
            withAnimation(.quick) {
                container.interactor.data.DeleteCard(budget, card)
            }
        }
    }
    
    var _AlertArchiveButton: some View {
        Button("global.archive", role: .destructive) {
            withAnimation(.quick) {
                container.interactor.data.ArchiveCard(budget, card)
            }
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
            CardRect(budget: .preview, card: .preview, isPreview: true, previewColor: .cyan)
                .frame(width: System.device.screen.width, height: System.device.screen.width*0.66)
                .padding()
                .inject(DIContainer.preview)
            CardRect(budget: .preview, card: .preview)
                .frame(width: System.device.screen.width*1.3, height: System.device.screen.width*0.66*1.3)
                .padding()
                .inject(DIContainer.preview)
            CardRect(budget: .preview, card: .preview2)
                .frame(width: System.device.screen.width, height: System.device.screen.width*0.66)
                .padding()
                .inject(DIContainer.preview)
        }
        .previewLayout(.sizeThatFits)
    }
}
