import SwiftUI
import UIComponent

struct DatePickerCustom<S>: View where S : DatePickerStyle {
    @Binding var datePicked: Date
    var start: Date
    var end: Date?
    var style: S
    var component: DatePickerComponents? = nil
    var cancelAction: () -> Void

    var body: some View {
        HalfSheet(grabber: false) {
            GeometryReader { bounds in
                VStack(alignment: .center, spacing: 0) {
                    headerBlock()
                        .padding([.horizontal, .top])
                        .onTapGesture { cancelAction() }
                    Spacer()
                    pickerBlock()
                    .padding(.horizontal)
                    .frame(width: bounds.size.width*0.9)
                    Spacer()
                }
            }
        }
    }
    
    @ViewBuilder
    private func headerBlock() -> some View {
        HStack {
            Block(width: 30, height: 10)
            Spacer()
            Text("日期")
                .font(.title3)
            Spacer()
            Image(systemName: "multiply.circle.fill")
                .foregroundColor(.primary25)
                .font(.title)
        }
    }
    
    @ViewBuilder
    private func pickerBlock() -> some View {
        VStack {
            if let end = end {
                if let comp = component {
                    DatePicker("", selection: $datePicked, in: start...end, displayedComponents: comp)
                        .labelsHidden()
                        .monospacedDigit()
                        .datePickerStyle(style)
                } else {
                    DatePicker("", selection: $datePicked, in: start...end)
                        .labelsHidden()
                        .monospacedDigit()
                        .datePickerStyle(style)
                }
            } else {
                if let comp = component {
                    DatePicker("", selection: $datePicked, in: start..., displayedComponents: comp)
                        .labelsHidden()
                        .monospacedDigit()
                        .datePickerStyle(style)
                } else {
                    DatePicker("", selection: $datePicked, in: start...)
                        .labelsHidden()
                        .monospacedDigit()
                        .datePickerStyle(style)
                    
                }
            }
        }
    }
    
}

#if DEBUG
struct DatePickerCustom_Previews: PreviewProvider {
    static var previews: some View {
        DatePickerCustom(datePicked: .constant(Date.now), start: Date.now, end: nil, style: .graphical) {
            print("Hello")
        }
    }
}
#endif
