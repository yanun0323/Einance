import SwiftUI
import UIComponent

enum InputType {
    case text, number
}

struct ExternalKeyboardPanel: View {
    @EnvironmentObject private var container: DIContainer
    @Binding var card: Card
    @Binding var time: Date
    @Binding var text: String
    @Binding var number: String
    @FocusState var focus: FocusField?
    @State var action: () -> Void = {}
    
    @State var textTags: [Tag] = []
    @State var numTags: [Tag] = []
    
    let switchButtonSize: CGFloat = 60
    
    init(card: Binding<Card>, time: Binding<Date>, text: Binding<String>, number: Binding<String>, focus: FocusState<FocusField?>, action: @escaping () -> Void) {
        self._card = card
        self._time = time
        self._text = text
        self._number = number
        self._focus = focus
        self.action = action
    }
    
    init(text: Binding<String>, number: Binding<String>, focus: FocusState<FocusField?>, action: @escaping () -> Void) {
        self._card = .constant(.empty)
        self._time = .constant(.zero)
        self._text = text
        self._number = number
        self._focus = focus
        self.action = action
    }
    
    
    var body: some View {
        ZStack {
            if !card.isZero {
                scrollRow(tags: getTags())
                    .padding(.trailing, switchButtonSize + 30)
            }
            if focus == .input || focus == .number {
                swithInputView()
                    .padding(.trailing)
            }
        }
        .padding(.vertical, 10)
        .backgroundColor(.transparent)
        .onAppear { handleRefreshTags() }
        .onChange(of: time) { _ in handleRefreshTags() }
    }
    
    @ViewBuilder
    private func swithInputView() -> some View {
        HStack {
            Spacer()
            ButtonCustom(width: switchButtonSize, height: switchButtonSize, color: .backgroundButton, radius: switchButtonSize/2, action: action) {
                Image(systemName: "arrow.left.arrow.right")
                    .foregroundColor(.primary75)
                    .font(.title)
                    .fontWeight(.light)
            }
        }
    }
    
    @ViewBuilder
    private func scrollRow(tags elem: [Tag]) -> some View {
        if let t = getType(), elem.count != 0 {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(elem, id: \.self) { e in
                        scrollButton(t, e.value)
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
    private func getTags() -> [Tag] {
        switch focus {
        case .input:
            return textTags
        case .number:
            return numTags
        default:
            return []
    }
    }
    
    private func handleRefreshTags() {
        if card.isZero { return }
        textTags = container.interactor.data.ListTags(card.chainID, .text, time.in24H)
        numTags = container.interactor.data.ListTags(card.chainID, .number, time.in24H)
    }
    
    private func getType() -> InputType? {
        switch focus {
            case .input:
                return .text
            case .number:
                return .number
            default:
                return nil
        }
    }
}

#if DEBUG
struct ExternalKeyboardPanel_Previews: PreviewProvider {
    static var previews: some View {
        ExternalKeyboardPanel(card: .constant(.preview), time: .constant(.now), text: .constant(""), number: .constant(""), focus: .init(), action: {})
            .preferredColorScheme(.dark)
            .inject(DIContainer.preview)
    }
}
#endif
