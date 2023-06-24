import SwiftUI
import Ditto

struct ViewHeader: View {
    @Environment(\.injected) private var container: DIContainer
    let title: LocalizedStringKey
    var length: CGFloat = 45
    
    var body: some View {
        HStack {
            Spacer()
            Text(title)
                .font(.title2)
            Spacer()
        }
    }
}

#if DEBUG
struct ViewHeader_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ViewHeader(title: "加入新的預算卡片")
                .inject(DIContainer.preview)
            ViewHeader(title: "加入新的預算卡片")
                .inject(DIContainer.preview)
        }
    }
}
#endif
