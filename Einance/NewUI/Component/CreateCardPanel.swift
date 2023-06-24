import SwiftUI
import Ditto

struct CreateCardPanel: View {
    @Environment(\.injected) private var container: DIContainer
    @FocusState private var focus: FocusField?
    @State private var nameInput = ""
    @State private var amountInput = ""
    @State private var displayInput: Card.Display = .month
    @State private var fColorInput: Color = .white
    @State private var bColorInput: Color = .cyan
    @State private var gColorInput: Color = .init(hex: "#2cc")
    @State private var pinnedInput = true
    @State private var creating = false
    @State private var useGColor: Bool = true
    
    @ObservedObject var budget: Budget
    
    var body: some View {
        ZStack {
            createCardBlock()
                .ignoresSafeArea(.keyboard)
            externalKeyboardClosePanel()
        }
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
    private func createCardBlock() -> some View {
        Self.sheetWrapper(title: "view.header.create.card", fColor: fColorInput, colors: [bColorInput, useGColor ? gColorInput : bColorInput]) {
            VStack(spacing: 20) {
                cardNameBlock()
                cardAmountBlock()
                HStack {
                    cardDisplayBlock()
                    Spacer()
                    cardFixedBlock()
                }
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
    private func cardDisplayBlock() -> some View {
        HStack {
            Text("panel.card.create.display.label")
                .font(Setting.cardPanelLabelFont)
            Menu {
                Picker("", selection: $displayInput) {
                    ForEach(Card.Display.avaliable) { display in
                        Text(display.string).tag(display)
                    }
                }
            } label: {
                Text(displayInput.string)
                    .font(Setting.cardPanelInputFont)
                    .frame(width: 80)
                    .animation(.none, value: displayInput)
                    .foregroundColor(bColorInput)
            }
            
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
    private func cardFixedBlock() -> some View {
        HStack {
            Text("panel.card.create.pinned.label")
                .font(Setting.cardPanelLabelFont)
            Toggle(isOn: $pinnedInput, color: $bColorInput, size: 24)
                .frame(width: 50)
        }
        .opacity(displayInput == .forever ? 0.1 : 1)
        .disabled(displayInput == .forever)
    }
    
    @ViewBuilder
    private func confirmButton() -> some View {
        ActionPanelConfirmButton(color: $bColorInput, text: "global.create") {
            withAnimation(.quick) {
                if creating { return }
                creating = true
                
                if nameInput.isEmpty {
                    nameInput = String(localized: "panel.card.create.name.label.placeholder")
                }
                
                if amountInput.isEmpty {
                    amountInput = String(localized: "panel.card.create.amount.label.placeholder")
                }
                
                guard let amount = Decimal(string: amountInput) else {
                    print("[ERROR] transform amount input to decimal failed")
                    creating = false
                    return
                }
                
                pinnedInput = pinnedInput || displayInput == .forever
                container.interactor.data.CreateCard(budget, name: nameInput, amount: amount, display: displayInput, fColor: fColorInput, bColor: bColorInput, gColor: useGColor ?  gColorInput : nil, pinned: pinnedInput)
                container.interactor.system.ClearActionView()
            }
        }
    }
    
}

struct CreateCardPanel_Previews: PreviewProvider {
    static var previews: some View {
        CreateCardPanel(budget: .preview)
            .inject(DIContainer.preview)
            .environment(\.locale, .tw)
    }
}
