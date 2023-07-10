import SwiftUI
import Ditto

struct EditRecordPanel: View {
    @Environment(\.injected) private var container: DIContainer
    @FocusState private var focus: FocusField?
    @State private var costInput: String
    @State private var dateInput: Date
    @State private var memoInput: String
    @State private var pinnedInput: Bool
    
    @State private var showDatePicker = false
    @State private var dateStart: Date = .zero
    @State private var dateEnd: Date? = nil
    @State private var updating: Bool = false
    
    @ObservedObject var budget: Budget
    @ObservedObject var record: Record
    @State var card: Card
    
    init(budget: Budget, card: Card, record: Record) {
        self._budget = .init(wrappedValue: budget)
        self._card = .init(wrappedValue: card)
        self._record = .init(wrappedValue: record)
        self._costInput = .init(wrappedValue:record.cost.description)
        self._dateInput = .init(wrappedValue:record.date)
        self._memoInput = .init(wrappedValue:record.memo)
        self._pinnedInput = .init(wrappedValue: record.pinned)
        if card.display.isForever { return }
        self.dateStart = record.date.firstDayOfMonth
        self.dateEnd = record.date.addMonth(1).addDay(-1)
    }
    
    var body: some View {
        ZStack {
            editRecordBlock()
                .ignoresSafeArea(.keyboard)
            externalKeyboardPanel()
        }
        .background(Color.background)
        .sheet(isPresented: $showDatePicker) {
            focus = .number
        } content: {
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
        .onAppeared { focus = .number }
    }
    
    @ViewBuilder
    private func externalKeyboardPanel() -> some View {
        VStack {
            Spacer()
            ExternalKeyboardPanel(card: $card, time: $dateInput, text: $memoInput, number: $costInput, focus: $focus) {
                focus = focus != .number ? .number : .input
            }
            .opacity(focus == .input || focus == .number ? 1 : 0)
            .animation(.none, value: focus)
        }
    }
    
    @ViewBuilder
    private func editRecordBlock() -> some View {
        Self.sheetWrapper(title: "view.header.edit.record", fColor: card.fColor, colors: card.bgColor) {
            VStack(spacing: 20) {
                recordCostBlock()
                recordMemoBlock()
                recordDateBlock()
                HStack {
                    targetCardBlock()
                    recordFixedBlock()
                }
                confirmButton()
                    .disabled(invalid)
                Spacer()
            }
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
                    .foregroundLinearGradient(card.bgColor)
                    .animation(.none, value: card)
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
                .keyboardType(.decimalPad)
                .font(Setting.cardPanelInputFont)
                .multilineTextAlignment(.trailing)
                .focused($focus, equals: .number)
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
            DatePicker("", selection: $dateInput)
                .datePickerStyle(.compact)
//            Button {
//                container.interactor.system.DismissKeyboard()
//                container.interactor.system.PushPickerState(isOn: true)
//                withAnimation(.quick) {
//                    showDatePicker = true
//                }
//            } label: {
//                Text(dateInput.String("yyyy.MM.dd hh:mm"))
//                    .monospacedDigit()
//                    .kerning(1)
//                    .foregroundColor(card.bColor)
//            }
        }
    }
    
    @ViewBuilder
    private func recordFixedBlock() -> some View {
        HStack {
            Text("panel.record.create.pinned.label")
                .font(Setting.cardPanelLabelFont)
            Toggle(isOn: $pinnedInput, color: $card.bColor, size: 24)
                .frame(width: 50)
        }
    }
    
    @ViewBuilder
    private func confirmButton() -> some View {
        ActionPanelConfirmButton(color: $card.bColor, text: "global.edit") {
            withAnimation(.quick) {
                if updating { return }
                updating = true
                
                guard let cost = Decimal(string: costInput) else {
                    print("[ERROR] transform cost input to decimal failed")
                    updating = false
                    return
                }
                
                let tagDate = dateInput.in24H
                container.interactor.data.EditTag(card.chainID, .text, tagDate, old: record.memo, new: memoInput)
                container.interactor.data.EditTag(card.chainID, .number, tagDate, old: record.cost.description, new: costInput)
                container.interactor.data.UpdateRecord(budget, card, record, date: dateInput, cost: cost, memo: memoInput, pinned: pinnedInput)
                
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
