import SwiftUI
import UIComponent

struct EditCardPanel: View {
    @EnvironmentObject private var container: DIContainer
    @FocusState private var focus: FocusField?
    @State private var nameInput: String
    @State private var amountInput: String
    @State private var displayInput: Card.Display
    @State private var colorInput: Color
    @State private var fixedInput: Bool
    private let isFixed: Bool
    
    @State private var updating: Bool = false
    
    @ObservedObject var budget: Budget
    @ObservedObject var card: Card
    
    init(budget: Budget, card: Card) {
        self._budget = .init(wrappedValue: budget)
        self._card = .init(wrappedValue: card)
        self._nameInput = .init(wrappedValue: card.name)
        self._amountInput = .init(wrappedValue: card.amount.description)
        self._displayInput = .init(wrappedValue: card.display)
        self._colorInput = .init(wrappedValue: card.color)
        self._fixedInput = .init(wrappedValue: card.fixed)
        self.isFixed = card.fixed || card.display == .forever
    }
    
    var body: some View {
        VStack {
            _TitleBlock
                .padding()
            VStack {
                _CardNameBlock
                _CardAmountBlock
                _CardColorBlock
//                _CardDisplayBlock
                _CardFixedBlock
            }
            .padding(.horizontal)
            ActionPanelConfirmButton(color: $colorInput, text: "global.edit") {
                withAnimation(.quick) {
                    if updating { return }
                    updating = true
                    
                    guard let amount = Decimal(string: amountInput) else {
                        print("[ERROR] transform amount input to decimal failed")
                        updating = false
                        return
                    }
                    
                    container.interactor.data.UpdateCard(budget, card, name: nameInput, amount: amount, color: colorInput, display: displayInput, fixed: fixedInput)
                    container.interactor.system.ClearActionView()
                }
            }
            .disabled(invalid)
        }
        .modifyPanelBackground()
        .padding()
        .onAppear {
            withAnimation(.quick) {
                focus = .input
            }
        }
    }
}

// MARK: - View Block
extension EditCardPanel {
    var _TitleBlock: some View {
        HStack {
            Text("panel.card.create.title")
                .font(Setting.panelTitleFont)
            Spacer()
            ActionPanelCloseButton()
        }
    }
    
    var _CardNameBlock: some View {
        HStack {
            Text("panel.card.create.name.label")
                .font(Setting.cardPanelLabelFont)
            TextField("panel.card.create.name.label.placeholder", text: $nameInput)
                .textFieldStyle(.plain)
                .font(Setting.cardPanelInputFont)
                .multilineTextAlignment(.trailing)
                .focused($focus, equals: .input)
        }
    }
    
    var _CardAmountBlock: some View {
        HStack {
            Text("panel.card.create.amount.label")
                .font(Setting.cardPanelLabelFont)
            TextField("panel.card.create.amount.label.placeholder", text: $amountInput)
                .textFieldStyle(.plain)
                .keyboardType(.decimalPad)
                .font(Setting.cardPanelInputFont)
                .multilineTextAlignment(.trailing)
        }
    }
    
    var _CardColorBlock: some View {
        HStack {
            Text("panel.card.create.color.label")
                .font(Setting.cardPanelLabelFont)
            ColorPicker(selection: $colorInput, label: {})
                .padding(.horizontal, 10)
        }
    }
    
    var _CardDisplayBlock: some View {
        HStack {
            Text("panel.card.create.display.label")
                .font(Setting.cardPanelLabelFont)
            Spacer()
            Menu {
                Picker("", selection: $displayInput) {
                    ForEach(Card.Display.allCases) { display in
                        if display != .forever {
                            Text(display.string).tag(display)
                        }
                    }
                }
            } label: {
                Text(displayInput.string)
                    .font(Setting.cardPanelInputFont)
                    .frame(width: 50)
                    .animation(.none, value: displayInput)
                    .foregroundColor(colorInput)
            }
        }
        .opacity(displayInput == .forever ? 0.1 : 1)
        .disabled(displayInput == .forever)
    }
    
    var _CardFixedBlock: some View {
        HStack {
            Text("panel.card.create.fixed.label")
                .font(Setting.cardPanelLabelFont)
            Spacer()
            ToggleCustom(isOn: $fixedInput, color: $colorInput, size: 24)
        }
        .opacity(displayInput == .forever ? 0.1 : 1)
        .disabled(displayInput == .forever)
    }
}

// MARK: - Property
extension EditCardPanel {
    var invalid: Bool {
        nameInput.count == 0 || Decimal(string: amountInput) == nil
    }
}

struct EditCardPanel_Previews: PreviewProvider {
    static var previews: some View {
        EditCardPanel(budget: .preview, card: .preview2)
            .inject(DIContainer.preview)
    }
}
