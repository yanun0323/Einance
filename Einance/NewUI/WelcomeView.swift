import SwiftUI
import Ditto

struct WelcomeView: View {
    @Environment(\.injected) private var container: DIContainer
    @State private var step: Int = 0
    @State private var baseDateNumber: Int = 5
    @State private var creating: Bool = false
    @State private var color: Color = .blue
    
    var body: some View {
        VStack {
            returnBlock()
            Spacer()
            stepRouter()
            Spacer()
            nextButton()
                .offset(x: step >= 2 ? -System.screen.width : 0)
            dotBlock()
        }
    }
    
    @ViewBuilder
    private func dotBlock() -> some View {
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
    
    @ViewBuilder
    private func returnBlock() -> some View {
        HStack {
            Button(width: 60, height: 70, radius: 5) {
                withAnimation(.medium) {
                    if creating { return }
                    if step <= 0 { return }
                    step -= 1
                }
            } content: {
                Image(systemName: "chevron.left")
                    .foregroundColor(color)
                    .font(.title2)
            }
            .shadow(radius: 5)
            Spacer()
        }
        .opacity(step == 0 ? 0 : 1)
    }
    
    @ViewBuilder
    private func nextButton() -> some View {
        Button(width: 120, height: 50, color: color, radius: 10) {
            withAnimation(.medium) {
                if step >= 2 { return }
                step += 1
            }
        } content: {
            Text("welcome.button.next")
                .foregroundColor(.white)
                .kerning(2)
        }
        .shadow(radius: 5)
    }
    
    @ViewBuilder
    private func stepRouter() -> some View {
        ZStack {
            stepLastView()
                .opacity(step == 2 ? 1 : 0)
                .disabled(step != 2)
                .offset(x: step != 2 ? System.screen.width : 0)
            
            step0View()
                .opacity(step != 0 ? 0.1 : 1)
                .scaleEffect(y: step != 0 ? 0.9 : 1, anchor: .top)
                .offset(
                    x: step >= 2 ? -System.screen.width : 0,
                    y: step != 0 ? -System.screen.height/4 : 0
                )
            
            step1View()
                .opacity(step == 1 ? 1 : 0)
                .scaleEffect(y: step != 0 ? 1 : 0.9, anchor: .bottom)
                .offset(
                    x: step >= 2 ? -System.screen.width : 0,
                    y: step == 0 ? 100 : 0
                )
        }
    }
    
    @ViewBuilder
    private func step0View() -> some View {
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
    
    @ViewBuilder
    private func step1View() -> some View {
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
                    .foregroundColor(color)
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
    
    @ViewBuilder
    private func stepLastView() -> some View {
        VStack(spacing: 20) {
            Text("welcome.step.2.content")
                .font(.title2)
            
            VStack {
                Button(width: 200, height: 50, color: color, radius: 10) {
                    handleComplete(true)
                } content: {
                    Text("welcome.button.tutorial.confirm")
                        .foregroundColor(.white)
                }
                .shadow(radius: 3)
                
                Button(width: 200, height: 50, color: .gray, radius: 10) {
                    handleComplete(false)
                } content: {
                    Text("welcome.button.tutorial.denine")
                        .foregroundColor(.white)
                }
                .shadow(radius: 3)
            }
            
        }
    }
}

extension WelcomeView {
    
    private func handleComplete(_ isTutorial: Bool) {
        withAnimation(.quick) {
            if creating { return }
            container.interactor.setting.SetAllTutorial(isTutorial)
            creating = true
            container.interactor.setting.SetBaseDateNumber(baseDateNumber)
            container.interactor.data.CreateFirstBudget()
        }
    }
    
}

#if DEBUG
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
            .inject(DIContainer.preview)
            .preferredColorScheme(.dark)
            .environment(\.locale, .us)
    }
}
#endif
