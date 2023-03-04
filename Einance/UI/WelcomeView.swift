import SwiftUI
import UIComponent

struct WelcomeView: View {
    @EnvironmentObject private var container: DIContainer
    var body: some View {
        VStack {
            Text("Welcome!!")
            Spacer()
            ButtonCustom(width: 200, height: 50, color: .blue, radius: 5, shadow: 3) {
                withAnimation(.quick) {
                    container.interactor.data.DebugCreateBudget()
                }
            } content: {
                Text("Create Budget")
                    .foregroundColor(.white)
            }
            Spacer()
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
