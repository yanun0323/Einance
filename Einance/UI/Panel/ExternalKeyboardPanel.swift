import SwiftUI
import UIComponent

enum InputType {
    case text, number
}

struct ExternalKeyboardPanel: View {
    @EnvironmentObject private var container: DIContainer
    @Binding var text: String
    @Binding var number: String
    @FocusState var focus: FocusField?
    @State var action: () -> Void
    
    #if DEBUG
    var show: Bool = false
    #endif
    
    let defaultTextRow: [String] = [
        "早餐","午餐","晚餐","飲料","零食","宵夜"
    ]
    
    let defaultNumberRow: [String] = [
        "10","50","100","150","200","300","500","1000"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            swithInputView()
                .padding(.horizontal, 10)
                .padding(.bottom, focus == .input || focus == .number ? 0 : 10)
            scrollRow()
                .padding(.vertical, 10)
                .backgroundColor(.transparent)
        }
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
            numberScrollRow()
        }
        #endif
        switch focus {
            case .input:
                textScrollRow()
            case .number:
                numberScrollRow()
            default:
                EmptyView()
        }
    }
    
    @ViewBuilder
    private func textScrollRow() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(defaultTextRow, id: \.self) { text in
                    scrollButton(.text, text)
                }
            }
        }
    }
    
    @ViewBuilder
    private func numberScrollRow() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(defaultNumberRow, id: \.self) { number in
                    scrollButton(.number, number)
                }
            }
        }
    }
    
    @ViewBuilder
    private func scrollButton(_ t: InputType, _ value: String) -> some View {
        Button {
            if t == .text {
                text = value
            } else {
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

#if DEBUG
struct ExternalKeyboardPanel_Previews: PreviewProvider {
    static var previews: some View {
        ExternalKeyboardPanel(text: .constant(""), number: .constant(""), action: {}, show: true)
            .preferredColorScheme(.dark)
            .inject(DIContainer.preview)
    }
}
#endif
