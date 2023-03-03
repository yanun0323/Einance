import SwiftUI
import UIComponent

struct CreateRecordPanel: View {
    @EnvironmentObject private var container: DIContainer
    @FocusState private var focus: FocusField?
    @State private var costInput = ""
    @State private var dateInput: Date = .now
    @State private var memoInput = ""
    @State private var showDatePicker = false
    @State private var dateStart: Date = .zero
    @State private var dateEnd: Date? = nil
    @State private var creating: Bool = false
    @State var today: Date
    @State var isForever: Bool
    @State var budget: Budget
    @Binding var card: Card
    
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    TitleBlock
                        .padding()
                    VStack {
                        RecordCostBlock
                        RecordMemoBlock
                        RecordDateBlock
                    }
                    .padding(.horizontal)
                    
                    ActionPanelConfirmButton(color: .constant(.blue), text: "global.create") {
                        withAnimation {
                            if creating { return }
                            creating = true
                            
                            guard let cost = Decimal(string: costInput) else {
                                print("[ERROR] transform cost input to decimal failed")
                                creating = false
                                return
                            }
                            let r = Record(cardID: card.id, date: dateInput, cost: cost, memo: memoInput)
                            let id = container.interactor.data.CreateRecord(r)
                            r.id = id
                            card.cost += r.cost
                            card.balance -= r.cost
                            if card.dateDict[r.date.unixDay] == nil {
                                card.dateDict[r.date.unixDay] = Card.RecordSet()
                            }
                            card.dateDict[r.date.unixDay]?.records.append(r)
                            card.dateDict[r.date.unixDay]?.cost += r.cost
                            
                            budget.cost += r.cost
                            budget.balance -= r.cost
                            
                            container.interactor.data.UpdateCard(card)
                            container.interactor.data.UpdateBudget(budget)
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
                    withAnimation {
                        container.interactor.system.PushPickerState(isOn: false)
                    }
                }
            }
            .onReceive(container.appstate.pickerPublisher) { output in
                if output { return }
                withAnimation {
                    showDatePicker = output
                }
            }
            .onAppear {
                focus = .input
                costInput = ""
                dateInput = today
                memoInput = ""
                if isForever { return }
                dateStart = today.firstDayOfMonth
                dateEnd = today.AddMonth(1).AddDay(-1)
            }
        }
        
    }
}

extension CreateRecordPanel {
    var TitleBlock: some View {
        HStack {
            Text("panel.record.create.title")
                .font(Setting.panelTitleFont)
            Spacer()
            ActionPanelCloseButton()
        }
    }
    
    
    var RecordCostBlock: some View {
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
    
    var RecordMemoBlock: some View {
        HStack {
            Text("panel.record.create.memo.label")
                .font(Setting.cardPanelLabelFont)
            TextField("panel.record.create.memo.placeholder", text: $memoInput)
                .textFieldStyle(.plain)
                .font(Setting.cardPanelInputFont)
                .multilineTextAlignment(.trailing)
        }
    }
    
    var RecordDateBlock: some View {
        HStack {
            Text("panel.record.create.date.label")
                .font(Setting.cardPanelLabelFont)
            Spacer()
            Button {
                container.interactor.system.DismissKeyboard()
                container.interactor.system.PushPickerState(isOn: true)
                withAnimation {
                    showDatePicker = true
                }
            } label: {
                Text(dateInput.String("yyyy.MM.dd hh:mm"))
                    .monospacedDigit()
                    .kerning(1)
                    .foregroundColor(.blue)
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
        CreateRecordPanel(today: .now, isForever: false, budget: .preview, card: .constant(.preview))
            .inject(DIContainer.preview)
    }
}
