import SwiftUI
import UIComponent

struct CardRectConcept: View {
    @Binding var fontColor: Color
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
        .foregroundColor(fontColor)
        .background(color)
        .cornerRadius(Setting.globalCornerRadius)
    }
}

extension CardRectConcept {
    
    private var title: CGFloat {
        return System.device.screen.width * 0.1
    }
    
    private var size: CGFloat {
        return System.device.screen.width - title*2
    }
    
}

struct CardRectConcept_Previews: PreviewProvider {
    static var previews: some View {
        CardRectConcept(fontColor: .constant(.white), color: .constant(.cyan))
    }
}
