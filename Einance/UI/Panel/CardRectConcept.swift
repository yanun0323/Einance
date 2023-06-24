import SwiftUI
import Ditto

struct CardRectConcept: View {
    @Binding var fColor: Color
    @Binding var color: Color
    
    var body: some View {
        HStack {
            Image(systemName: "triangle.fill")
            Image(systemName: "squareshape.fill")
            Image(systemName: "circle.fill")
            Image(systemName: "multiply")
                .font(.system(size: title*1.2))
                .fontWeight(.heavy)
        }
        .font(.system(size: title))
        .frame(width: size, height: size*0.66)
        .foregroundColor(fColor)
        .background(color)
        .cornerRadius(Setting.globalCornerRadius)
    }
}

extension CardRectConcept {
    
    private var title: CGFloat {
        return System.screen.width * 0.1
    }
    
    private var size: CGFloat {
        return System.screen.width - title*2
    }
    
}

struct CardRectConcept_Previews: PreviewProvider {
    static var previews: some View {
        CardRectConcept(fColor: .constant(.white), color: .constant(.cyan))
    }
}
