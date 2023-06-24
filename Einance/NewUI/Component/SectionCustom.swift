import SwiftUI

public struct SectionCustom<V>: View where V: View {
    var title: LocalizedStringKey
    var font: Font
    var color: Color
    var radius: CGFloat
    var bg: Color
    var content: () -> V
    
    public init(
        _ title: LocalizedStringKey, font: Font = .caption, color: Color = .section,
        radius: CGFloat = 15,
        bg: Color = .section.opacity(0.5), content: @escaping () -> V
    ) {
        self.title = title
        self.font = font
        self.color = color
        self.radius = radius
        self.bg = bg
        self.content = content
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if title != "" {
                Text(title)
                    .font(font)
                    .foregroundColor(color)
                    .padding(.leading, 5)
            }
            content()
                .background(bg)
                .cornerRadius(radius)
        }
    }
}

struct SectionCustom_Previews: PreviewProvider {
    static var previews: some View {
        SectionCustom("123") {
            Text("Hello")
        }
    }
}
