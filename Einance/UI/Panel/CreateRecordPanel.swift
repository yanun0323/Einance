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
    @ObservedObject var card: Card
    
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

extension CreateRecordPanel {
    var _TitleBlock: some View {
        HStack {
            Text("panel.record.create.title")
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

extension CreateRecordPanel {
    var invalid: Bool {
        Decimal(string: costInput) == nil
    }
}

struct CreateRecordPanel_Previews: PreviewProvider {
    static var previews: some View {
        CreateRecordPanel(budget: .preview, card: .preview, today: .now)
            .inject(DIContainer.preview)
    }
}
