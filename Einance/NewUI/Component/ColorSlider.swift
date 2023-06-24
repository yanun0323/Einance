import SwiftUI
import Ditto
import Combine

struct ColorSlider: View {
    @GestureState private var dragOffset: CGFloat = .zero
    @State private var endOffset: CGFloat
    
    @Binding var value: CGFloat
    var `in`: ClosedRange<CGFloat>
    @Binding var selectedColor: Color
    @Binding var valueChangedFromOutside: Bool
    @State var width: CGFloat
    @State var height: CGFloat
    @Binding var colors: [Color]
    @State var onRelease: () -> Void
    
    var maxTravel: CGFloat { (width-height)/2 }
    
    init(value: Binding<CGFloat>,`in`: ClosedRange<CGFloat>, selectedColor: (Binding<Color>)? = nil, updateTrigger force: (Binding<Bool>)? = nil, width: CGFloat = 250, height: CGFloat = 50, colors: (Binding<[Color]>)? = nil, onRelease: @escaping () -> Void = {}) {
        self._value = value
        self.`in` = `in`
        self._selectedColor = selectedColor ?? .init(get: { .transparent }, set: { _ in})
        self._valueChangedFromOutside = force ?? .init(get: { false }, set: { _ in})
        self.width = width
        self.height = height
        self._colors = colors ?? .init(get: {[.black, .white]}, set: { _ in})
        self.onRelease = onRelease
        let ratio = (width-height) / (`in`.lowerBound+`in`.upperBound)
        self.endOffset = value.wrappedValue*ratio - ((width-height)/2)
    }
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .foregroundColor(selectedColor)
                    .shadow(radius: 5)
                Circle()
                    .stroke(lineWidth: 2)
                    .foregroundColor(.background)
            }
            .padding(3)
            .offset(x: dragOffset + endOffset)
            .gesture(
                DragGesture()
                    .updating($dragOffset, body: { v, state, _ in
                        let offset = handleDraging(v.translation.width)
                        state = offset
                        DispatchQueue.main.async {
                            value = calculateValue(offset+endOffset)
                        }
                    })
                    .onEnded({ v in
                        endOffset += handleDraging(v.translation.width)
                        value = calculateValue(endOffset)
                        onRelease()
                    })
            )
        }
        .frame(width: width, height: height)
        .backgroundLinearGradient(colors, start: .leading, end: .trailing)
        .cornerRadius(height)
        .shadow(radius: 5)
        .onAppeared { calculateOffset() }
        .onChanged(of: valueChangedFromOutside) { _ in calculateOffset()}
    }
}

fileprivate extension ColorSlider {
    func handleDraging(_ trans: CGFloat) -> CGFloat {
        let travel = trans + endOffset
        if travel < -maxTravel { return -maxTravel-endOffset }
        if travel > maxTravel { return maxTravel-endOffset }
        return trans
    }
    
    func calculateValue(_ offset: CGFloat) -> CGFloat {
        let (min, max) = (`in`.lowerBound, `in`.upperBound)
        if offset < -maxTravel { return min }
        if offset > maxTravel*2 { return max }
        let ratio = (max-min) / (maxTravel*2)
        return (offset+maxTravel) * ratio
    }

    func calculateOffset() {
        let ratio = (maxTravel*2) / (`in`.lowerBound+`in`.upperBound)
        self.endOffset = value*ratio - maxTravel
    }
}

struct Slider_Previews: PreviewProvider {
    @State static var value: CGFloat = 255
    static var previews: some View {
        VStack {
            Text(value.description)
                .frame(width: 200)
            ColorSlider(value: $value, in: 0...255, selectedColor: .constant(.red))
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
