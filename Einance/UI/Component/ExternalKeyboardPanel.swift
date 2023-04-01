import SwiftUI
import UIComponent

enum InputType {
    case text, number
}

struct ExternalKeyboardPanel: View {
    @EnvironmentObject private var container: DIContainer
    @State var chainID: UUID? = nil
    @Binding var time: Date
    @Binding var text: String
    @Binding var number: String
    @FocusState var focus: FocusField?
    @State var action: () -> Void
    
    #if DEBUG
    var show: Bool = false
    #endif
    
    @State var textRow: [String] = []
    @State var numRow: [String] = []
    
    var body: some View {
        VStack(spacing: 0) {
            swithInputView()
                .padding(.horizontal, 10)
                .padding(.bottom, showRow() ? 0 : 10)
            if !chainID.isNil {
                scrollRow()
                    .padding(.vertical, 10)
                    .backgroundColor(.transparent)
            }
        }
        .onAppear { handleRefreshTags() }
        .onChange(of: time) { _ in handleRefreshTags() }
        .animation(.none, value: focus)
    }
    
    @ViewBuilder
    private func swithInputView() -> some View {
        HStack {
            Spacer()
            ButtonCustom(width: 60, height: 60, color: .backgroundButton, radius: 30, shadow: 2, action: action) {
                Image(systemName: "arrow.right.to.line.compact")
                    .foregroundColor(.primary75)
                    .font(.title)
                    .fontWeight(.light)
            }
        }
    }
    
    @ViewBuilder
    private func scrollRow() -> some View {
        #if DEBUG
        if show {
            textScrollRow()
        }
        #endif
        switch focus {
            case .input:
                textScrollRow()
            case .number:
                numScrollRow()
            default:
                EmptyView()
        }
    }
    
    @ViewBuilder
    private func textScrollRow() -> some View {
        if textRow.count != 0 {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(textRow, id: \.self) { text in
                        scrollButton(.text, text)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func numScrollRow() -> some View {
        if numRow.count != 0 {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(numRow, id: \.self) { num in
                        scrollButton(.number, num)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func scrollButton(_ t: InputType, _ value: String) -> some View {
        Button {
            switch t {
                case .text:
                    text = value
                case .number:
                    number = value
            }
        } label: {
            Text(value)
                .fontWeight(.medium)
                .foregroundColor(.primary75)
                .kerning(1)
                .padding(.vertical, 10)
                .padding(.horizontal)
                .backgroundColor(.backgroundButton)
                .cornerRadius(10)
        }
        .padding(.horizontal, 5)
    }
    
}

extension ExternalKeyboardPanel {
    func showRow() -> Bool {
        if chainID.isNil { return false }
        switch focus {
            case .input:
                return textRow.count != 0
            case .number:
                return numRow.count != 0
            default:
                return false
        }
    }
    
    func handleRefreshTags() {
        guard let cID = chainID else { return }
        textRow = container.interactor.data.GetTags(cID, .text, time.in24H)
        numRow = container.interactor.data.GetTags(cID, .number, time.in24H)
    }
}

#if DEBUG
struct ExternalKeyboardPanel_Previews: PreviewProvider {
    static var previews: some View {
        ExternalKeyboardPanel(chainID: .init(), time: .constant(.now), text: .constant(""), number: .constant(""), action: {}, show: true)
            .preferredColorScheme(.dark)
            .inject(DIContainer.preview)
    }
}
#endif
