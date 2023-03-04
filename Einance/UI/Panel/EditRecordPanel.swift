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
    
    @ObservedObject var current: Current
    @ObservedObject var card: Card
    @ObservedObject var record: Record
    
    init(current: Current, card: Card, record: Record) {
        self._current = .init(wrappedValue: current)
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
                    _TitleBlock
                        .padding()
                    VStack {
                        _RecordCostBlock
                        _RecordMemoBlock
                        _RecordDateBlock
                    }
                    .padding(.horizontal)
                    
                    ActionPanelConfirmButton(color: $card.color, text: "global.edit") {
                        withAnimation(.quick) {
                            if updating { return }
                            updating = true
                            
                            guard let cost = Decimal(string: costInput) else {
                                print("[ERROR] transform cost input to decimal failed")
                                updating = false
                                return
                            }
                            
                            container.interactor.data.UpdateRecord(current.budget, card, record, date: dateInput, cost: cost, memo: memoInput, fixed: fixedInput)
                            container.interactor.system.ClearActionView()
                        }
                    }
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
            .onReceive(container.appstate.keyboardPublisher) { output in
                if output {
                    withAnimation(.quick) {
                        container.interactor.system.PushPickerState(isOn: false)
                    }
                }
            }
            .onReceive(container.appstate.pickerPublisher) { output in
                if output { return }
                withAnimation(.quick) {
                    showDatePicker = output
                }
            }
            .onAppear {
                withAnimation(.quick) {
                    focus = .input
                }
            }
        }
    }
}

extension EditRecordPanel {
    var _TitleBlock: some View {
        HStack {
            Text("panel.record.edit.title")
                .font(Setting.panelTitleFont)
            Spacer()
            ActionPanelCloseButton()
        }
    }
    
    
    var _RecordCostBlock: some View {
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
    
    var _RecordMemoBlock: some View {
        HStack {
            Text("panel.record.create.memo.label")
                .font(Setting.cardPanelLabelFont)
            TextField("panel.record.create.memo.placeholder", text: $memoInput)
                .textFieldStyle(.plain)
                .font(Setting.cardPanelInputFont)
                .multilineTextAlignment(.trailing)
        }
    }
    
    var _RecordDateBlock: some View {
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
}

extension EditRecordPanel {
    var invalid: Bool {
        Decimal(string: costInput) == nil
    }
}

struct EditRecordPanel_Previews: PreviewProvider {
    static var previews: some View {
        EditRecordPanel(current: .preview, card: .preview, record: .preview)
            .inject(DIContainer.preview)
    }
}
