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
    
    @ObservedObject var current: Current
    
    init(current: Current) {
        self._current = .init(wrappedValue: current)
        self.displayInput = .month
        self.amountInput = ""
    }
    
    var body: some View {
        VStack {
            _TitleBlock
                .padding()
            VStack(spacing: 10) {
                _CardNameBlock
                _CardAmountBlock
                _CardColorBlock
                _CardDisplayBlock
                _CardFixedBlock
            }
            .padding(.horizontal)
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
                    
                    container.interactor.data.CreateCard(current.budget, name: nameInput, amount: amount, display: displayInput, color: colorInput, fixed: fixedInput)
                    container.interactor.system.ClearActionView()
                }
            }
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
extension CreateCardPanel {
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
    
    var _CardFixedBlock: some View {
        HStack {
            Text("panel.card.create.fixed.label")
                .font(Setting.cardPanelLabelFont)
            Spacer()
            ToggleCustom(isOn: $fixedInput, color: $colorInput, size: 24)
        }
    }
}

// MARK: - Property
extension CreateCardPanel {}

struct CreateCardPanel_Previews: PreviewProvider {
    static var previews: some View {
        CreateCardPanel(current: .preview)
            .inject(DIContainer.preview)
    }
}
