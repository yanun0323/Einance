import SwiftUI
import Ditto

struct CardColorPicker: View {
    @State private var type: ColorSliderPanel.SliderType = .rgb
    private var w: CGFloat { System.screen(.width, 0.8) }
    
    @Binding var fColor: Color
    @Binding var bColor: Color
    @Binding var gColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            cardPreview()
            tab()
            Text("panel.card.create.f_color.label")
            ColorSliderPanel(color: $fColor, width: w, type: $type)
            Text("panel.card.create.b_color.label")
            ColorSliderPanel(color: $bColor, width: w, type: $type)
            ColorSliderPanel(color: $gColor, width: w, type: $type)
        }
        .font(.system(size: 24))
        .fontWeight(.regular)
    }
    
    @ViewBuilder
    private func tab() -> some View {
        let (w, h):(CGFloat, CGFloat) = (w/2, 40)
        HStack(spacing: 0) {
            ForEach(ColorSliderPanel.SliderType.allCases, id: \.self) { t in
                Button(width: w, height: h, color: .transparent) {
                    withAnimation {
                        type = t
                    }
                } content: {
                    Text(t.string)
                        .foregroundColor(t == type ? .primary75 : .section)
                        .font(.system(size: 22))
                        .kerning(5)
                }
            }
        }
        .font(.system(size: 20))
        .background {
            HStack(spacing: 0) {
                if type == .hsv { Spacer() }
                RoundedRectangle(cornerRadius: h*0.2)
                    .frame(width: w)
                    .foregroundColor(.background)
                    .shadow(radius: 5)
                if type == .rgb { Spacer() }
            }
            .padding(3)
            .background(Color.section)
            .cornerRadius(h*0.3)
        }
    }
    
    @ViewBuilder
    private func cardPreview() -> some View {
        LinearGradient(colors: [bColor, gColor], startPoint: .topLeading, endPoint: .trailing)
            .frame(width: w, height: w*0.5)
            .overlay {
                VStack {
                    HStack {
                        Text("+−×÷")
                            .foregroundColor(fColor)
                            .font(.system(size: w*0.2, weight: .medium))
                        Spacer()
                    }
                    Spacer()
                }
                .padding(.horizontal)
            }
            .cornerRadius(20)
    }
}

struct ColorSliderPanel: View {
    @State private var triggerRGB: Bool = false
    @State private var r: CGFloat = 0
    @State private var rSlider: [Color] = [.black, .red]
    @State private var g: CGFloat = 0
    @State private var gSlider: [Color] = [.black, .green]
    @State private var b: CGFloat = 0
    @State private var bSlider: [Color] = [.black, .blue]
    
    @State private var triggerHSV: Bool = false
    @State private var h: CGFloat = 0
    @State private var hSelectedColor: Color = .red
    @State private var s: CGFloat = 100
    @State private var sSlider: [Color] = [.black]
    @State private var v: CGFloat = 100
    @State private var vSlider: [Color] = [.black]
    
    @Binding var color: Color
    @State var width: CGFloat = 250
    @Binding var type: SliderType
    
    var body: some View {
        VStack(spacing: 30) {

            if type == .rgb {
                rgbTab()
            } else {
                hsvTab()
            }
        }
        .onChanged(of: r) { _ in calculateRGB() }
        .onChanged(of: g) { _ in calculateRGB() }
        .onChanged(of: b) { _ in calculateRGB() }
        .onChanged(of: h) { _ in calculateHSV() }
        .onChanged(of: s) { _ in calculateHSV() }
        .onChanged(of: v) { _ in calculateHSV() }
        .onAppeared { decodeStartColor() }
    }
    
    @ViewBuilder
    private func rgbTab() -> some View {
        VStack {
            slider("R", $r, in: 0...255, .r)
            slider("G", $g, in: 0...255, .g)
            slider("B", $b, in: 0...255, .b)
        }
    }
    
    @ViewBuilder
    private func hsvTab() -> some View {
        VStack {
            slider("H", $h, in: 0...360, .h)
            slider("S", $s, in: 0...100, .s)
            slider("V", $v, in: 0...100, .v)
        }
    }
    
    @ViewBuilder
    private func slider(_ title: String, _ value: Binding<CGFloat>, in bounds: ClosedRange<CGFloat>, step: CGFloat = 0.1, _ type: ColorType) -> some View {
        ColorSlider(value: value, in: bounds, selectedColor: selectedColor(type), updateTrigger: colorTrigger(type), width: width, height: 30, colors: sliderColor(type)) {
            switch type {
                case .r, .g, .b:
                    rgb2hsv()
                case .h, .s, .v:
                    hsv2rgb()
            }
        }
    }
}

extension ColorSliderPanel {
    enum SliderType: CaseIterable {
        case rgb, hsv
        
        var string: String {
            switch self {
                case .rgb:
                    return "RGB"
                case .hsv:
                    return "HSV"
            }
        }
        
        func `is`(_ b: (Binding<SliderType>)?) -> Bool {
            if b == nil {
                return self == .rgb
            }
            return self == b!.wrappedValue
        }
    }
}

fileprivate extension ColorSliderPanel {
    func decodeStartColor() {
        let c = color.components ?? (1, 1, 1, 1)
        r = (c.red * 255)
        b = (c.blue * 255)
        g = (c.green * 255)
        rgb2hsv()
    }
    
    func sliderColor(_ type: ColorType) -> (Binding<[Color]>)? {
        switch type {
            case .r:
                return _rSlider.projectedValue
            case .g:
                return _gSlider.projectedValue
            case .b:
                return _bSlider.projectedValue
            case .h:
                var h: [Color] = []
                for i in 0...100 {
                    h.append(Color(hue: Double(i)/100, saturation: 1, brightness: 1))
                }
                return .constant(h)
            case .s:
                return _sSlider.projectedValue
            case .v:
                return _vSlider.projectedValue
        }
    }
    
    func selectedColor(_ type: ColorType) -> (Binding<Color>)? {
        switch type {
            case .h:
                return _hSelectedColor.projectedValue
            default:
                return _color.projectedValue
        }
    }
    
    func colorTrigger(_ type: ColorType) -> (Binding<Bool>)? {
        switch type {
            case .r, .g, .b:
                return _triggerRGB.projectedValue
            case .h, .s, .v:
                return _triggerHSV.projectedValue
        }
    }
    
    func calculateRGB() {
        let (dR, dG, dB) = (r/255, g/255, b/255)
        color = Color(red: dR, green: dG, blue: dB)
        rSlider = [Color(red: 0, green: dG, blue: dB), Color(red: 1, green: dG, blue: dB)]
        gSlider = [Color(red: dR, green: 0, blue: dB), Color(red: dR, green: 1, blue: dB)]
        bSlider = [Color(red: dR, green: dG, blue: 0), Color(red: dR, green: dG, blue: 1)]
    }
    
    func calculateHSV() {
        let (dH, dS, dV) = (h/360, s/100, v/100)
        _color.wrappedValue = Color(hue: dH, saturation: dS, brightness: dV)
        hSelectedColor = Color(hue: dH, saturation: 1, brightness: 1)
        sSlider = [Color(hue: dH, saturation: 0, brightness: dV),
                   Color(hue: dH, saturation: 1, brightness: dV)]
        vSlider = [Color(hue: dH, saturation: dS, brightness: 0),
                   Color(hue: dH, saturation: dS, brightness: 1)]
    }
    
    func rgb2hsv() {
        let hsv = Util.rgb2hsv(r: r, g: g, b: b)
        h = hsv.h
        s = hsv.s
        v = hsv.v
        triggerHSV.toggle()
    }
    
    func hsv2rgb() {
        let rgb = Util.hsv2rgb(h: h, s: s/100, v: v/100)
        r = rgb.r
        g = rgb.g
        b = rgb.b
        triggerRGB.toggle()
    }
}

fileprivate extension ColorSliderPanel {
    enum ColorType {
        case r, g, b, h, s, v
    }
}

struct CardColorPicker_Previews: PreviewProvider {
    static var fColor: Color = .white
    static var bColor: Color = .cyan
    static var gColor: Color = .green
    static var previews: some View {
        CardColorPicker(
            fColor: .init(get: {fColor}, set: {fColor=$0}),
            bColor: .init(get: {bColor}, set: {bColor=$0}),
            gColor: .init(get: {gColor}, set: {gColor=$0}))
            .backgroundColor(.background)
            .preferredColorScheme(.dark)
        ColorSliderPanel(color: .init(get: {bColor}, set: {bColor=$0}), width: 200, type: .constant(.hsv))
    }
}


