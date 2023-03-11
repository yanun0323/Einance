import SwiftUI
import UIComponent

struct WelcomeView: View {
    @EnvironmentObject private var container: DIContainer
    @State private var step: Int = 0
    @State private var baseDateNumber: Int = 5
    @State private var creating: Bool = false
    
    var body: some View {
        VStack {
            _ReturnBlock
            Spacer()
            _StepRouter
            Spacer()
            _NextButton
                .offset(x: step >= 2 ? -System.device.screen.width : 0)
            _DotBlock
        }
        
    }
}

extension WelcomeView {
    var _DotBlock: some View {
        HStack {
            ForEach(0...2, id: \.self) { i in
                Circle()
                    .frame(width: 7, height: 7)
                    .foregroundColor(step == i ? .gray : .section)
            }
        }
        .padding()
        .animation(.quick, value: step)
    }
    
    var _ReturnBlock: some View {
        HStack {
            ButtonCustom(width: 60, height: 70, radius: 5, shadow: 5) {
                withAnimation(.medium) {
                    if creating { return }
                    if step <= 0 { return }
                    step -= 1
                }
            } content: {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
                    .font(.title2)
            }
            Spacer()
        }
        .opacity(step == 0 ? 0 : 1)
    }
    
    var _NextButton: some View {
        ButtonCustom(width: 120, height: 50, color: .blue, radius: 10, shadow: 5) {
            withAnimation(.medium) {
                if step >= 2 { return }
                step += 1
            }
        } content: {
            Text("welcome.button.next")
                .foregroundColor(.white)
                .kerning(2)
        }
    }
    
    var _StepRouter: some View {
        ZStack {
            _StepLastView
                .opacity(step == 2 ? 1 : 0)
                .disabled(step != 2)
                .offset(x: step != 2 ? System.device.screen.width : 0)
            
            _Step0View
                .opacity(step != 0 ? 0.1 : 1)
                .scaleEffect(y: step != 0 ? 0.9 : 1, anchor: .top)
                .offset(
                    x: step >= 2 ? -System.device.screen.width : 0,
                    y: step != 0 ? -System.device.screen.height/4 : 0
                )
            
            _Step1View
                .opacity(step == 1 ? 1 : 0)
                .scaleEffect(y: step != 0 ? 1 : 0.9, anchor: .bottom)
                .offset(
                    x: step >= 2 ? -System.device.screen.width : 0,
                    y: step == 0 ? 100 : 0
                )
        }
    }
    
    var _Step0View: some View {
        VStack(spacing: 20) {
            Text("welcome.step.0.title")
                .font(.title)
                .kerning(2)
            Text("welcome.step.0.content")
                .font(.callout)
                .foregroundColor(.gray)
        }
        .fontWeight(.light)
    }
    
    var _Step1View: some View {
        VStack(spacing: 30) {
            Text("welcome.step.1.title")
                .font(.title)
                .kerning(2)
            HStack {
                Text("welcome.step.1.picker.left")
                Picker("", selection: $baseDateNumber) {
                    ForEach(1...31, id: \.self) { i in
                        Text(i.description)
                            .font(.title)
                            .tag(i)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 80, height: 150)
                Text("welcome.step.1.picker.right")
            }
            .font(.title)
            Text("welcome.step.1.content")
                .font(.body)
                .foregroundColor(.gray)
        }
        .fontWeight(.light)
    }
    
    var _StepLastView: some View {
        VStack(spacing: 20) {
            Text("welcome.step.2.content")
                .font(.title2)
            
            VStack {
                ButtonCustom(width: 200, height: 50, color: .blue, radius: 10, shadow: 3) {
                    withAnimation(.quick) {
//                        if creating { return }
//                        creating = true
                    }
                } content: {
                    Text("welcome.button.tutorial.confirm")
                        .foregroundColor(.white)
                }
                
                ButtonCustom(width: 200, height: 50, color: .gray, radius: 10, shadow: 3) {
                    withAnimation(.quick) {
                        if creating { return }
                        creating = true
                        container.interactor.setting.SetBaseDateNumber(baseDateNumber)
                        container.interactor.data.CreateFirstBudget()
                    }
                } content: {
                    Text("welcome.button.tutorial.denine")
                        .foregroundColor(.white)
                }
            }
            
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
