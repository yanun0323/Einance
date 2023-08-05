import SwiftUI

struct TextFieldCustom: UIViewRepresentable {
    var alignment: NSTextAlignment
    var titleKey: String
    var view: UIView?
    @Binding var text: String
    
    init(alignment: NSTextAlignment = .right, _ titleKey: String = "", text: Binding<String>) {
        self.alignment = alignment
        self.titleKey = titleKey.localized
        self._text = text
    }
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.inputView = UIView() // hiding keyboard
        textField.inputDelegate = nil
        textField.inputAccessoryView = UIView() // hiding keyboard toolbar
        textField.placeholder = titleKey
        textField.textColor = UIColor(Color.primary)
        textField.font = UIFont.systemFont(ofSize: 20.0)
        textField.delegate = context.coordinator
        textField.textAlignment = .right
        return textField
    }
    
    func updateUIView(_ textField: UITextField, context: Context) {
        textField.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        init(text: Binding<String>) {
            self._text = text
        }
    }
}

struct TextFieldCustom_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldCustom("global.edit", text: .constant(""))
    }
}
