import SwiftUI
import UIComponent

struct EditRecordPanel: View {
    @EnvironmentObject private var container: DIContainer
    @FocusState private var focus: FocusField?
    @State private var costInput = ""
    @State private var dateInput: Date = .now
    @State private var memoInput = ""
    @State private var showDatePicker = false
    @State private var dateStart: Date = .zero
    @State private var dateEnd: Date? = nil
    @State var record: Record
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
                    
                    ActionPanelConfirmButton(color: .constant(.blue), text: "global.edit") {
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
                focus = .input
                costInput = record.cost.description
                dateInput = record.date
                memoInput = record.memo
                if isForever { return }
                dateStart = record.date.firstDayOfMonth
                dateEnd = record.date.AddMonth(1).AddDay(-1)
            }
        }
    }
}

extension EditRecordPanel {
    var TitleBlock: some View {
        HStack {
            Text("panel.record.edit.title")
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
                .focused($focus, equals: .input)
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

extension EditRecordPanel {
    var invalid: Bool {
        Decimal(string: costInput) == nil
    }
}

struct EditRecordPanel_Previews: PreviewProvider {
    static var previews: some View {
        EditRecordPanel(record: .preview, isForever: false)
            .inject(DIContainer.preview)
    }
}
