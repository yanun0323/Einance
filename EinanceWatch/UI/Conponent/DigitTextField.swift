import SwiftUI
import Ditto

fileprivate enum DigitButtonType {
    case number, dot, delete
}

struct DigitTextField: View {
    @State private var present: Bool = false
    @State private var input: String = "0"
    @Binding var text: String
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 7)
                .foregroundColor(.section)
                .frame(height: 40)
                .overlay {
                    HStack {
                        Spacer()
                        ZStack {
                            Text("0")
                                .opacity(text.isEmpty ? 0.2 : 0)
                            Text(text)
                        }
                        .padding(.trailing)
                        .lineLimit(1)
                        .monospacedDigit()
                        .truncationMode(.middle)
                    }
                }
                .onTapGesture {
                    input = "0"
                    present = true
                }
        }
        .sheet(isPresented: $present) { inputSheet() }
    }
    
    @ViewBuilder
    private func inputSheet() -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .bottom) {
                Spacer()
                Text(input)
                    .font(.title2)
                    .lineLimit(1)
                    .monospacedDigit()
                    .minimumScaleFactor(0.5)
                    .truncationMode(.middle)
                    .padding(.trailing, System.screen(.width, 0.1))
            }
            .frame(height: System.screen(.height, 0.2), alignment: .center)

            digitPad()
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    text = input
                    present.toggle()
                }
                .foregroundColor(.blue)
            }
        }
        .ignoresSafeArea(.all)
        .padding(.top, 15)
    }
    
    @ViewBuilder
    private func digitPad() -> some View {
        VStack {
            HStack {
                button(value: "7")
                button(value: "8")
                button(value: "9")
            }
            HStack {
                button(value: "4")
                button(value: "5")
                button(value: "6")
            }
            HStack {
                button(value: "1")
                button(value: "2")
                button(value: "3")
            }
            HStack {
                button(value: ".", .dot)
                button(value: "0")
                button(value: "⌫", .delete)
            }
        }
    }
    
    @ViewBuilder
    private func button(value: String, _ type: DigitButtonType = .number) -> some View {
        Button(width: System.screen(.width, 0.29), height: System.screen(.height, 0.13), color: .section, radius: System.screen(.height, 0.04)) {
            switch type {
                case .number:
                    if input == "0" {
                        input = value
                        return
                    }
                    input.append(value)
                case .dot:
                    if input == "0" || input.contains(".") { return }
                    input.append(".")
                case .delete:
                    if input.count == 1 {
                        input = "0"
                        return
                    }
                    input = String(input.dropLast(1))
            }
        } content: {
            Text(value)
        }
    }
}

#if DEBUG
struct DigitTextField_Previews: PreviewProvider {
    @State static var text: String = "0"
    static var previews: some View {
        VStack {
            DigitTextField(text: $text)
            TextField("", text: .constant("jgioerjagre;g"))
                .multilineTextAlignment(.trailing)
        }
    }
}
#endif
