import SwiftUI
import UIComponent

struct EditRecordPanel: View {
    @EnvironmentObject private var container: DIContainer
    @FocusState private var focus: FocusField?
    @State private var costInput: String
    @State private var dateInput: Date
    @State private var memoInput: String
    @State private var fixedInput: Bool
    
    @State private var showDatePicker = false
    @State private var dateStart: Date = .zero
    @State private var dateEnd: Date? = nil
    @State private var updating: Bool = false
    
    @ObservedObject var budget: Budget
    @ObservedObject var card: Card
    @ObservedObject var record: Record
    
    init(budget: Budget, card: Card, record: Record) {
        self._budget = .init(wrappedValue: budget)
        self._card = .init(wrappedValue: card)
        self._record = .init(wrappedValue: record)
        self._costInput = .init(wrappedValue:record.cost.description)
        self._dateInput = .init(wrappedValue:record.date)
        self._memoInput = .init(wrappedValue:record.memo)
        self._fixedInput = .init(wrappedValue: record.fixed)
        if card.display.isForever { return }
        self.dateStart = record.date.firstDayOfMonth
        self.dateEnd = record.date.AddMonth(1).AddDay(-1)
    }
    
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    titleBlock()
                        .padding()
                    VStack {
                        recordCostBlock()
                        recordMemoBlock()
                        recordDateBlock()
                        recordFixedBlock()
                    }
                    .padding(.horizontal)
                    
                    confirmButton()
                        .disabled(invalid)
                }
                .modifyPanelBackground()
                .padding()
                Spacer()
            }
            .sheet(isPresented: $showDatePicker) {
                DatePickerCustom(datePicked: $dateInput, start: dateStart, end: dateEnd, style: .graphical) {
                    container.interactor.system.PushPickerState(isOn: false)
                }
            }
            .onReceived(container.appstate.keyboardPublisher) {
                if !$0 { return }
                container.interactor.system.PushPickerState(isOn: false)

            }
            .onReceived(container.appstate.pickerPublisher) {
                if $0 { return }
                showDatePicker = $0
            }
            .onAppeared { focus = .input }
        }
    }
    
    @ViewBuilder
    private func titleBlock() -> some View {
        HStack {
            Text("view.header.edit.record")
                .font(Setting.panelTitleFont)
            Spacer()
            ActionPanelCloseButton()
        }
    }
    
    
    @ViewBuilder
    private func recordCostBlock() -> some View {
        HStack {
            Text("panel.record.create.cost.label")
                .font(Setting.cardPanelLabelFont)
            TextField("panel.record.create.cost.placeholder", text: $costInput)
                .textFieldStyle(.plain)
                .keyboardType(.decimalPad)
                .font(Setting.cardPanelInputFont)
                .multilineTextAlignment(.trailing)
                .focused($focus, equals: .input)
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
            Spacer()
            ToggleCustom(isOn: $fixedInput, color: $card.color, size: 24)
        }
    }
    
    @ViewBuilder
    private func confirmButton() -> some View {
        ActionPanelConfirmButton(color: $card.color, text: "global.edit") {
            withAnimation(.quick) {
                if updating { return }
                updating = true
                
                guard let cost = Decimal(string: costInput) else {
                    print("[ERROR] transform cost input to decimal failed")
                    updating = false
                    return
                }
                
                container.interactor.data.UpdateRecord(budget, card, record, date: dateInput, cost: cost, memo: memoInput, fixed: fixedInput)
                container.interactor.system.ClearActionView()
            }
        }
    }
    
}

extension EditRecordPanel {
    var invalid: Bool {
        Decimal(string: costInput) == nil
    }
}

#if DEBUG
struct EditRecordPanel_Previews: PreviewProvider {
    static var previews: some View {
        EditRecordPanel(budget: .preview, card: .preview, record: .preview)
            .inject(DIContainer.preview)
    }
}
#endif
