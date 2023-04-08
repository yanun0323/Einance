import SwiftUI
import UIComponent

struct CreateRecordPanel: View {
    @EnvironmentObject private var container: DIContainer
    @FocusState private var focus: FocusField?
    @State private var costInput = ""
    @State private var dateInput: Date = .now
    @State private var memoInput = ""
    @State private var fixedInput: Bool = false
    @State private var showDatePicker = false
    @State private var dateStart: Date = .zero
    @State private var dateEnd: Date? = nil
    @State private var creating: Bool = false
    
    @ObservedObject var budget: Budget
    @State var card: Card
    
    init(budget: Budget, card: Card, today: Date = .now) {
        self._budget = .init(wrappedValue: budget)
        self._card = .init(wrappedValue: card)
        self.costInput = ""
        self.dateInput = today
        self.memoInput = ""
        if card.display.isForever { return }
        dateStart = today.firstDayOfMonth
        self.dateEnd = today.AddMonth(1).AddDay(-1)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            createRecordBlock()
                .padding([.horizontal, .top])
            Spacer()
            externalKeyboardPanel()
        }
        .animation(.quick, value: focus)
        .sheet(isPresented: $showDatePicker) {
            DatePickerCustom(datePicked: $dateInput, start: dateStart, end: dateEnd, style: .graphical) {
                container.interactor.system.PushPickerState(isOn: false)
                focus = .number
            }
        }
        .onReceived(container.appstate.keyboardPublisher) {
            if !$0 { return }
            container.interactor.system.PushPickerState(isOn: false)
        }
        .onReceived(container.appstate.pickerPublisher) {
            if $0 { return }
            showDatePicker = false
        }
        .onAppeared { focus = .number }
    }
    
    @ViewBuilder
    private func externalKeyboardPanel() -> some View {
        ExternalKeyboardPanel(chainID: card.chainID, time: $dateInput, text: $memoInput, number: $costInput, focus: _focus) {
            focus = focus != .number ? .number : .input
        }
    }
    
    @ViewBuilder
    private func calculatorKeyboard() -> some View {
        VStack {
            Spacer()
            CalculatorKeyboard(input: $costInput) {
                self.focus = .input
            }
            .disabled(focus != .number)
            .offset(y: focus == .number ? 0 : System.device.screen.height/2)
        }
    }
    
    @ViewBuilder
    private func createRecordBlock() -> some View {
        VStack {
            titleBlock()
                .padding()
            VStack(spacing: 10) {
                recordCostBlock()
                recordMemoBlock()
                recordDateBlock()
                
                HStack {
                    targetCardBlock()
                    recordFixedBlock()
                }
            }
            .padding(.horizontal)
            
            confirmButton()
                .disabled(invalid)
        }
        .modifyPanelBackground()
    }
    
    @ViewBuilder
    private func titleBlock() -> some View {
        HStack {
            Text("view.header.create.record")
                .font(Setting.panelTitleFont)
            Spacer()
            ActionPanelCloseButton()
        }
    }
    
    @ViewBuilder
    private func targetCardBlock() -> some View {
        HStack {
            Text("panel.record.create.target_card.label")
                .font(Setting.cardPanelLabelFont)
            Spacer()
            Menu {
                Picker("", selection: $card) {
                    ForEach(budget.book) { c in
                        Text(c.name).tag(c)
                    }
                }
            } label: {
                Text(card.name)
                    .font(Setting.cardPanelInputFont)
                    .frame(width: 120 ,alignment: .center)
                    .animation(.none, value: card)
                    .foregroundColor(card.fontColor)
                    .padding(.vertical, 5)
                    .backgroundColor(card.color)
                    .cornerRadius(5)
                    .lineLimit(1)
            }
            
            Spacer()
        }
    }
    
    
    @ViewBuilder
    private func recordCostBlock() -> some View {
        HStack {
            Text("panel.record.create.cost.label")
                .font(Setting.cardPanelLabelFont)
            TextField("panel.record.create.cost.placeholder", text: $costInput)
                .textFieldStyle(.plain)
                .font(Setting.cardPanelInputFont)
                .multilineTextAlignment(.trailing)
                .focused($focus, equals: .number)
                .keyboardType(.decimalPad)
        }
    }
    
    @ViewBuilder
    private func recordMemoBlock() -> some View {
        HStack {
            Text("panel.record.create.memo.label")
                .font(Setting.cardPanelLabelFont)
            TextField("panel.record.create.memo.placeholder", text: $memoInput)
                .textFieldStyle(.plain)
                .font(Setting.cardPanelInputFont)
                .multilineTextAlignment(.trailing)
                .focused($focus, equals: .input)
        }
    }
    
    @ViewBuilder
    private func recordDateBlock() -> some View {
        HStack {
            Text("panel.record.create.date.label")
                .font(Setting.cardPanelLabelFont)
            Spacer()
            Button {
                container.interactor.system.DismissKeyboard()
                container.interactor.system.PushPickerState(isOn: true)
                withAnimation(.quick) {
                    showDatePicker = true
                }
            } label: {
                Text(dateInput.String("yyyy.MM.dd hh:mm"))
                    .monospacedDigit()
                    .kerning(1)
                    .foregroundColor(card.color)
            }

        }
    }
    
    @ViewBuilder
    private func recordFixedBlock() -> some View {
        HStack {
            Text("panel.record.create.fixed.label")
                .font(Setting.cardPanelLabelFont)
            ToggleCustom(isOn: $fixedInput, color: $card.color, size: 24)
                .frame(width: 50)
        }
    }
    
    @ViewBuilder
    private func confirmButton() -> some View {
        ActionPanelConfirmButton(color: $card.color, text: "global.create") {
            withAnimation(.quick) {
                if creating { return }
                creating = true
                
                guard let cost = Decimal(string: costInput) else {
                    print("[ERROR] transform cost input to decimal failed")
                    creating = false
                    return
                }
                
                container.interactor.data.CreateRecord(budget, card, date: dateInput, cost: cost, memo: memoInput, fixed: fixedInput)
                let tagDate = dateInput.in24H
                container.interactor.data.CreateTag(card.chainID, .text, memoInput, tagDate)
                container.interactor.data.CreateTag(card.chainID, .number, costInput, tagDate)
                
                container.interactor.system.ClearActionView()
            }
        }
    }
}

extension CreateRecordPanel {
    var invalid: Bool {
        Decimal(string: costInput) == nil
    }
}

#if DEBUG
struct CreateRecordPanel_Previews: PreviewProvider {
    static var previews: some View {
        CreateRecordPanel(budget: .preview, card: .preview, today: .now)
            .inject(DIContainer.preview)
    }
}
#endif
