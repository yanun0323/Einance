import SwiftUI
import UIComponent

struct CreateRecordPanel: View {
    @EnvironmentObject private var container: DIContainer
    @FocusState private var focus: FocusField?
    @State private var record = Record()
    @State private var costInput = ""
    @State private var dateInput: Date = .now
    @State private var memoInput = ""
    @State private var showDatePicker = false
    @State private var dateStart: Date = .zero
    @State private var dateEnd: Date? = nil
    @State var today: Date
    @State var isForever: Bool
    
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
                record = Record()
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
        CreateRecordPanel(today: .now, isForever: false)
            .inject(DIContainer.preview)
    }
}
