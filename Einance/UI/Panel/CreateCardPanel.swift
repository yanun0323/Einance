import SwiftUI
import UIComponent

struct CreateCardPanel: View {
    @EnvironmentObject private var container: DIContainer
    @FocusState private var focus: FocusField?
    @State private var nameInput = ""
    @State private var amountInput = ""
    @State private var displayInput: Card.Display = .month
    @State private var colorInput: Color = .blue
    @State private var fixedInput = false
    @State private var creating = false
    
    @ObservedObject var budget: Budget
    
    var body: some View {
        VStack {
            titleBlock()
                .padding()
            VStack {
                cardNameBlock()
                cardAmountBlock()
                cardColorBlock()
                cardDisplayBlock()
                cardFixedBlock()
            }
            .padding(.horizontal)
            confirmButton()
        }
        .modifyPanelBackground()
        .padding()
        .onAppeared { focus = .input }
    }
    
    @ViewBuilder
    private func titleBlock() -> some View {
        HStack {
            Text("view.header.create.card")
                .font(Setting.panelTitleFont)
            Spacer()
            ActionPanelCloseButton()
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
        }
    }
    
    @ViewBuilder
    private func cardColorBlock() -> some View {
        HStack {
            Text("panel.card.create.color.label")
                .font(Setting.cardPanelLabelFont)
            ColorPicker(selection: $colorInput, label: {})
                .padding(.horizontal, 10)
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
                    ForEach(Card.Display.avaliable) { display in
                        Text(display.string).tag(display)
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
    }
    
    @ViewBuilder
    private func cardFixedBlock() -> some View {
        HStack {
            Text("panel.card.create.fixed.label")
                .font(Setting.cardPanelLabelFont)
            Spacer()
            ToggleCustom(isOn: $fixedInput, color: $colorInput, size: 24)
        }
        .opacity(displayInput == .forever ? 0.1 : 1)
        .disabled(displayInput == .forever)
    }
    
    @ViewBuilder
    private func confirmButton() -> some View {
        ActionPanelConfirmButton(color: $colorInput, text: "global.create") {
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
                
                fixedInput = fixedInput || displayInput == .forever
                container.interactor.data.CreateCard(budget, name: nameInput, amount: amount, display: displayInput, color: colorInput, fixed: fixedInput)
                container.interactor.system.ClearActionView()
            }
        }
    }
    
}

struct CreateCardPanel_Previews: PreviewProvider {
    static var previews: some View {
        CreateCardPanel(budget: .preview)
            .inject(DIContainer.preview)
    }
}
