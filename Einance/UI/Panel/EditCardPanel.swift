import SwiftUI
import UIComponent

struct EditCardPanel: View {
    @EnvironmentObject private var container: DIContainer
    @FocusState private var focus: FocusField?
    @State private var nameInput = ""
    @State private var amountInput = ""
    @State private var displayInput: Card.Display = .month
    @State private var colorInput: Color = .blue
    @State private var fixedInput = false
    @State var card: Card
    var body: some View {
        VStack {
            TitleBlock
                .padding()
            VStack {
                CardNameBlock
                CardAmountBlock
                CardColorBlock
                if card.display != .forever {
                    CardDisplayBlock
                    CardFixedBlock
                }
            }
            .padding(.horizontal)
            ActionPanelConfirmButton(color: $colorInput, text: "global.edit") {
                withAnimation {
                    container.interactor.system.ClearActionView()
                }
            }
            .disabled(invalid)
        }
        .modifyPanelBackground()
        .padding()
        .onAppear {
            focus = .input
            nameInput = card.name
            amountInput = card.amount.description
            displayInput = card.display
            colorInput = card.color
            fixedInput = card.fixed
        }
    }
}

// MARK: - View Block
extension EditCardPanel {
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
extension EditCardPanel {
    var invalid: Bool {
        nameInput.count == 0 || Decimal(string: amountInput) == nil
    }
}

struct EditCardPanel_Previews: PreviewProvider {
    static var previews: some View {
        EditCardPanel(card: .preview)
            .inject(DIContainer.preview)
    }
}
