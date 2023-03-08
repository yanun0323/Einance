import SwiftUI
import UIComponent

struct WelcomeView: View {
    @EnvironmentObject private var container: DIContainer
    var body: some View {
        VStack {
            Spacer()
            Text("- Monthly Check 會把固定卡片的全部細項都 Copy\n- 固定花費功能(沒固定卡片無法固定花費)")
            ButtonCustom(width: 200, height: 50, color: .blue, radius: 5, shadow: 3) {
                withAnimation(.quick) {
                    container.interactor.data.CreateFirstBudget()
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
