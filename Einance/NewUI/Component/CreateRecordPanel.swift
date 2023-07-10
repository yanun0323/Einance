import SwiftUI
import Ditto

struct CreateRecordPanel: View {
    @Environment(\.injected) private var container: DIContainer
    @FocusState private var focus: FocusField?
    @State private var costInput = ""
    @State private var dateInput: Date = .now
    @State private var memoInput = ""
    @State private var pinnedInput: Bool = false
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
        self.dateEnd = today.addMonth(1).addDay(-1)
    }
    
    var body: some View {
        ZStack {
            createRecordBlock()
                .ignoresSafeArea(.keyboard)
            externalKeyboardPanel()
        }
        .background(Color.background)
        .animation(.quick, value: focus)
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
            showDatePicker = false
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
    private func calculatorKeyboard() -> some View {
        VStack {
            Spacer()
            CalculatorKeyboard(input: $costInput) {
                self.focus = .input
            }
            .disabled(focus != .number)
            .offset(y: focus == .number ? 0 : System.screen.height/2)
        }
    }
    
    @ViewBuilder
    private func createRecordBlock() -> some View {
        Self.sheetWrapper(title: "view.header.create.record", fColor: card.fColor, colors: card.bgColor) {
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
        ActionPanelConfirmButton(color: $card.bColor, text: "global.create") {
            withAnimation(.quick) {
                if creating { return }
                creating = true
                
                guard let cost = Decimal(string: costInput) else {
                    print("[ERROR] transform cost input to decimal failed")
                    creating = false
                    return
                }
                
                container.interactor.data.CreateRecord(budget, card, date: dateInput, cost: cost, memo: memoInput, pinned: pinnedInput)
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
