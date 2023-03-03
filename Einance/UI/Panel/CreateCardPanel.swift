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
    
    var body: some View {
        VStack {
            TitleBlock
                .padding()
            VStack {
                CardNameBlock
                CardAmountBlock
                CardColorBlock
                CardDisplayBlock
                CardFixedBlock
            }
            .padding(.horizontal)
            ActionPanelConfirmButton(color: $colorInput, text: "global.create") {
                withAnimation {
                    if creating { return }
                    creating = true
                    
                    if nameInput.isEmpty {
                        nameInput = String(localized: "panel.card.create.name.label.placeholder")
                    }
                    
                    if amountInput.isEmpty {
                        amountInput = String(localized: "panel.card.create.amount.label.placeholder")
                    }
                    
                    let b = container.interactor.data.CurrentBudget()
                    let card = Card(
                        budgetID: b.id,
                        index: b.book.count,
                        name: nameInput,
                        amount: Decimal(string: amountInput) ?? 0,
                        display: displayInput,
                        color: colorInput,
                        fixed: fixedInput
                    )
                    let cardID = container.interactor.data.CreateCard(card)
                    card.id = cardID
                    
                    b.book.append(card)
                    b.amount += card.amount
                    b.book.sort { c1, c2 in
                        c1.index < c2.index
                    }
                    
                    container.interactor.data.SetCurrentBudget(b)
                    container.interactor.system.ClearActionView()
                }
            }
            .disabled(invalid)
        }
        .modifyPanelBackground()
        .padding()
        .onAppear {
            displayInput = .month
            focus = .input
            amountInput = ""
        }
    }
}

// MARK: - View Block
extension CreateCardPanel {
    var TitleBlock: some View {
        HStack {
            Text("panel.card.create.title")
                .font(Setting.panelTitleFont)
            Spacer()
            ActionPanelCloseButton()
        }
    }
    
    var CardNameBlock: some View {
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
    
    var CardAmountBlock: some View {
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
    
    var CardColorBlock: some View {
        HStack {
            Text("panel.card.create.color.label")
                .font(Setting.cardPanelLabelFont)
            ColorPicker(selection: $colorInput, label: {})
                .padding(.horizontal, 10)
        }
    }
    
    var CardDisplayBlock: some View {
        HStack {
            Text("panel.card.create.display.label")
                .font(Setting.cardPanelLabelFont)
            Spacer()
            Menu {
                Picker("", selection: $displayInput) {
                    ForEach(Card.Display.allCases) { display in
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
    
    var CardFixedBlock: some View {
        HStack {
            Text("panel.card.create.fixed.label")
                .font(Setting.cardPanelLabelFont)
            Spacer()
            ToggleCustom(isOn: $fixedInput, color: $colorInput, size: 24)
        }
    }
}

// MARK: - Property
extension CreateCardPanel {
    var invalid: Bool {
        return false
        nameInput.count == 0 || Decimal(string: amountInput) == nil
    }
}

struct CreateCardPanel_Previews: PreviewProvider {
    static var previews: some View {
        CreateCardPanel()
            .inject(DIContainer.preview)
    }
}
