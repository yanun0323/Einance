import SwiftUI
import Ditto
import UIKit

private enum Operater: String {
    case add = "add", sub = "sub", mul = "mul", div = "div", equ = "equ", ac = "ac", c = "c", dot = "dot"
}

struct CalculatorKeyboard: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var input: String
    @State var action: () -> Void
    
    private let rowCount: CGFloat = 5
    private let colCount: CGFloat = 4
    
    private var unitHeight: CGFloat
    private var unitWidth: CGFloat
    private var unitRadius: CGFloat
    private var unitDiameter: CGFloat
    private var unitGap: CGFloat = 10
    private var fontSize: CGFloat
    
    @State private var resValue: Decimal?
    @State private var tmpValue: Decimal?
    @State private var currOp: Operater = .equ
    @State private var prevOp: Operater = .equ
    @State private var digit: Decimal = 1
    @State private var needClearTmp: Bool = false
    @State private var zeroFix: Int = 0
    
//    @State private var value: String = ""
    
    init(input: Binding<String>, action: @escaping () -> Void = {}) {
        self._input = input
        self._action = .init(wrappedValue: action)
        
        let w = System.screen.width
        let h = System.screen.height / 2 - 15
        unitWidth = (w - ((colCount + 1) * unitGap)) / colCount
        unitHeight = (h - ((rowCount + 1) * unitGap)) / rowCount
        unitDiameter = unitHeight < unitWidth ? unitHeight : unitWidth
        unitRadius = unitDiameter / 3
        fontSize = unitDiameter / 2
    }
    
    var body: some View {
        
//        Text(value)
//            .font(.largeTitle)
//        Text(resValue?.description ?? "nil")
//            .font(.largeTitle)
//        Text(resValue?.exponent.description ?? "-")
//            .font(.title)
//        Text(tmpValue?.description ?? "nil")
//            .font(.largeTitle)
//        Text(tmpValue?.exponent.description ?? "-")
//            .font(.title)
//        Text("currOP \(currOp.rawValue)")
//            .font(.title)
//        Text("prevOp \(prevOp.rawValue)")
//            .font(.title2)
//        Text("needClearTmp \(needClearTmp.description)")
//            .font(.title3)
        
        HalfSheet(grabber: false) {
            Spacer()
            HStack(alignment: .bottom, spacing: unitGap) {
                VStack(spacing: unitGap) {
                    HStack(spacing: unitGap) {
                        if tmpValue.isNil {
                            operateButton("AC", .ac, bgColor: .gray, fontScale: 0.8)
                        } else {
                            operateButton("C", .c, bgColor: .gray, fontScale: 0.9)
                        }
                        
                        operateButton("÷", .div)
                        operateButton("×", .mul)
                    }
                    HStack(spacing: unitGap) {
                        numButton(7)
                        numButton(8)
                        numButton(9)
                    }
                    HStack(spacing: unitGap) {
                        numButton(4)
                        numButton(5)
                        numButton(6)
                    }
                    HStack(spacing: unitGap) {
                        numButton(1)
                        numButton(2)
                        numButton(3)
                    }
                    HStack(spacing: unitGap) {
                        numButton(0, scaleW: 2)
                        operateButton(".", .dot, color: .primary75, bgColor: .section)
                    }
                }
                VStack(spacing: unitGap) {
                    buttonBlueprint(.backgroundButton) {
                        dismiss()
                    } content: {
                        Image(systemName: "arrow.right.to.line.compact")
                            .foregroundColor(.primary75)
                            .font(.title)
                            .fontWeight(.light)
                    }
                    
                    operateButton("−", .sub)
                    operateButton("+", .add)
                    operateButton("=", .equ, scaleH: 2)
                }
            }
        }
//        } action: {
//            UIApplication.shared.DismissKeyboard()
//            action()
//            print("container disappear")
//        }
        .onAppear {
            resValue = Decimal(string: input)
        }
        .onDisappear {
            print("disappear")
        }
//        .padding(unitGap)
//        .padding(.bottom, 15)
//        .frame(width: System.screen.width, height: System.screen.height/2)
//        .backgroundColor(.background)
//        .cornerRadius(15)
//        .shadow(radius: 3)
    }
    
    @ViewBuilder
    private func numButton(_ value: Decimal, scaleW: CGFloat = 1, scaleH: CGFloat = 1) -> some View {
        buttonBlueprint(.section, scaleW, scaleH)  {
            self.inputValue(value)
        } content: {
            Text(value.description)
                .font(.system(size: self.fontSize))
                .foregroundColor(.primary75)
        }

    }
    
    @ViewBuilder
    private func operateButton(_ text: String, _ operate: Operater, color: Color = .white, bgColor: Color = .orange, scaleW: CGFloat = 1, scaleH: CGFloat = 1, fontScale: CGFloat = 1.2) -> some View {
        let c = (operate != .equ && currOp == operate && (tmpValue.isNil || needClearTmp)) ? bgColor.opacity(0.7) : bgColor
        buttonBlueprint(c, scaleW, scaleH) {
            self.handleOperation(operate)
        } content: {
            Text(text)
                .font(.system(size: self.fontSize*fontScale))
                .foregroundColor(color)
        }
    }
    
    @ViewBuilder
    private func buttonBlueprint(_ color: Color = .orange, _ scaleW: CGFloat = 1, _ scaleH: CGFloat = 1, action: @escaping () -> Void, @ViewBuilder content: @escaping () -> some View) -> some View {
        let gap = abs(unitWidth - unitHeight) / 2
        let width = ((unitDiameter+gap) * scaleW) + ((scaleW - 1) * unitGap)
        let height = (unitHeight * scaleH) + ((scaleH - 1) * unitGap)
        Button(width: width, height: height, color: color, radius: unitRadius, action: action, content: content)
    }
}

extension CalculatorKeyboard {
    private func inputValue(_ num: Decimal) {
        if needClearTmp {
            tmpValue = nil
            needClearTmp = false
        }
        if currOp == .equ {
            resValue = nil
        }
        if digit == 1 {
            tmpValue = (tmpValue ?? 0) * 10 + num
        } else {
            tmpValue = (tmpValue ?? 0) + (num * digit)
            digit *= 0.1
        }
        output(tmpValue)
        if num.isZero && digit != 1 {
            let e = tmpValue!.exponent
            if  e >= 0 {
//                value += "."
                input += "."
            }
            if e <= 0 {
                zeroFix += 1
            }
            for _ in 0 ..< zeroFix {
//                value += "0"
                input += "0"
            }
        } else {
            zeroFix = 0
        }
    }
    
    private func output(_ num: Decimal?, needDot: Bool = false) {
        guard let d = num else {
            input = ""
//            value = ""
            return
        }
        var f = (d.exponent >= 0) ? 0 : abs(d.exponent)
        if f > 10 { f = 10 }
        input = String(format: "%.\(f)f\(needDot ? "." : "")", d.double)
//        value = String(format: "%.\(f)f\(needDot ? "." : "")", d.ToDouble())
    }
    
    private func handleOperation(_ nextOp: Operater) {
        if needClearTmp {
            tmpValue = nil
        }
        switch nextOp {
            case .add, .sub, .mul, .div:
                invokeCurrOp(isNextEqual: false)
                output(resValue)
                currOp = nextOp
            case .equ:
                invokeCurrOp(isNextEqual: true)
                output(resValue)
                currOp = nextOp
            case .c:
                digit = 1
                tmpValue = nil
                zeroFix = 0
                output(resValue)
            case .ac:
                resValue = nil
                tmpValue = nil
                digit = 1
                zeroFix = 0
                currOp = .ac
                output(resValue)
            case .dot:
                if digit != 1 { return }
                if tmpValue.isNil { tmpValue = 0 }
                digit *= 0.1
                output(tmpValue, needDot: true)
        }
    }
    
    private func invokeCurrOp(isNextEqual: Bool) {
        if isNextEqual && currOp == .equ { currOp = prevOp }
        defer {
            digit = 1
            prevOp = currOp
            needClearTmp = true
            zeroFix = 0
        }
        guard let tmp = tmpValue else { return }
        if resValue.isNil {
            resValue = tmp
            tmpValue = nil
            needClearTmp = true
            return
        }
        switch currOp {
            case .add:
                resValue = (resValue ?? 0) + tmp
            case .sub:
                resValue = (resValue ?? 0) - tmp
            case .mul:
                resValue = (resValue ?? 0) * tmp
            case .div:
                if tmp == 0 { return }
                if resValue.isNil || resValue! == 0 { return }
                resValue = (resValue ?? 0) / tmp
            default:
                return
        }
    }
}


