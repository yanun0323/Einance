import SwiftUI
import Ditto

struct EditCardPanel: View {
    @Environment(\.injected) private var container: DIContainer
    @FocusState private var focus: FocusField?
    @State private var nameInput: String
    @State private var amountInput: String
    @State private var displayInput: Card.Display
    @State private var fColorInput: Color
    @State private var bColorInput: Color
    @State private var gColorInput: Color
    @State private var pinnedInput: Bool
    @State private var useGColor: Bool
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
        self._fColorInput = .init(wrappedValue: card.fColor)
        self._bColorInput = .init(wrappedValue: card.bColor)
        self._gColorInput = .init(wrappedValue: card.gColor ?? card.bColor)
        self._pinnedInput = .init(wrappedValue: card.pinned)
        self._useGColor = .init(wrappedValue: card.gColor != nil)
        self.isFixed = card.pinned || card.display == .forever
    }
    
    var body: some View {
        ZStack {
            editCardBlock()
                .ignoresSafeArea(.keyboard)
            externalKeyboardClosePanel()
        }
        .background(Color.background)
        .onAppeared { focus = .input }
    }
    
    @ViewBuilder
    private func externalKeyboardClosePanel() -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                ExternalKeyboardSwitcher {
                    focus = focus != .input ? .input : .number
                }
                .padding(.trailing)
            }
            .opacity(focus == .input || focus == .number ? 1 : 0)
            .animation(.none, value: focus)
        }
        .padding(.vertical, 10)
    }
    
    @ViewBuilder
    private func editCardBlock() -> some View {
        Self.sheetWrapper(title: "view.header.edit.card", fColor: fColorInput, colors: [bColorInput, useGColor ? gColorInput : bColorInput]) {
            VStack(spacing: 20) {
                cardNameBlock()
                cardAmountBlock()
                // cardDisplayBlock
                cardFixedBlock()
                cardFColorBlock()
                cardBColorBlock()
                confirmButton()
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private func cardNameBlock() -> some View {
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
    
    @ViewBuilder
    private func cardAmountBlock() -> some View {
        HStack {
            Text("panel.card.create.amount.label")
                .font(Setting.cardPanelLabelFont)
            TextField("panel.card.create.amount.label.placeholder", text: $amountInput)
                .textFieldStyle(.plain)
                .keyboardType(.decimalPad)
                .font(Setting.cardPanelInputFont)
                .multilineTextAlignment(.trailing)
                .focused($focus, equals: .number)
        }
    }
    
    @ViewBuilder
    private func cardFColorBlock() -> some View {
        HStack {
            Text("panel.card.create.f_color.label")
                .font(Setting.cardPanelLabelFont)
            Spacer()
            ColorPicker(selection: $fColorInput, label: {})
                .frame(width: 30)
                .padding(.horizontal, 10)
        }
    }
    
    @ViewBuilder
    private func cardBColorBlock() -> some View {
        HStack {
            Text("panel.card.create.b_color.label")
                .font(Setting.cardPanelLabelFont)
            Spacer()
            ColorPicker(selection: $bColorInput, label: {})
                .frame(width: 30)
                .padding(.horizontal, 10)
            ColorPicker(selection: $gColorInput, label: {})
                .frame(width: 30)
                .padding(.horizontal, 10)
                .opacity(useGColor ? 1 : 0.2)
                .disabled(!useGColor)
            Toggle(isOn: $useGColor, color: $bColorInput)
        }
    }
    
    @ViewBuilder
    private func cardDisplayBlock() -> some View {
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
                    .foregroundLinearGradient([bColorInput, useGColor ? gColorInput : bColorInput])
            }
        }
        .opacity(displayInput == .forever ? 0.1 : 1)
        .disabled(displayInput == .forever)
    }
    
    @ViewBuilder
    private func cardFixedBlock() -> some View {
        HStack {
            Text("panel.card.create.pinned.label")
                .font(Setting.cardPanelLabelFont)
            Spacer()
            Toggle(isOn: $pinnedInput, color: $bColorInput, size: 24)
        }
        .opacity(displayInput == .forever ? 0.1 : 1)
        .disabled(displayInput == .forever)
    }
    
    @ViewBuilder
    private func confirmButton() -> some View {
        ActionPanelConfirmButton(color: $bColorInput, text: "global.edit") {
            withAnimation(.quick) {
                if updating { return }
                updating = true
                
                guard let amount = Decimal(string: amountInput) else {
                    print("[ERROR] transform amount input to decimal failed")
                    updating = false
                    return
                }
                
                container.interactor.data.UpdateCard(budget, card, name: nameInput, index: card.index, amount: amount, fColor: fColorInput, bColor: bColorInput, gColor: useGColor ? gColorInput : nil, display: displayInput, pinned: pinnedInput)
                container.interactor.system.ClearActionView()
            }
        }
        .disabled(invalid)
    }
}

// MARK: - Property
extension EditCardPanel {
    var invalid: Bool {
        nameInput.count == 0 || Decimal(string: amountInput) == nil
    }
}

#if DEBUG
struct EditCardPanel_Previews: PreviewProvider {
    static var previews: some View {
        EditCardPanel(budget: .preview, card: .preview2)
            .inject(DIContainer.preview)
    }
}
#endif
