import SwiftUI
import UIComponent

struct LoadingSymbol: View {
    @State private var isLoading = false
    let size: CGFloat
    let duration: Double
    
    init(size: CGFloat = 15, duration: Double = 0.5) {
        self.size = size
        self.duration = duration
    }
    
    
    var body: some View {
        HStack(spacing: 20) {
            ForEach(0...2, id: \.self) { index in
                Circle()
                    .frame(width: size, height: size)
                    .foregroundColor(getColor(index))
                    .scaleEffect(self.isLoading ? 0.5 : 1, anchor: .center)
                    .opacity(self.isLoading ? 0.5 : 1)
                    .offset(x: self.isLoading ? 0 : CGFloat(2*index-2), y: self.isLoading ? 0 : -5)
                    .animation(.easeInOut(duration: duration).repeatForever(autoreverses: true).delay(0.15 * Double(index)), value: isLoading)
            }
        }
        .onAppear {
            withAnimation {
                isLoading = true
            }
        }
    }
    
    func getColor(_ index: Int) -> Color {
        return .primary.opacity(0.3 * Double(3-index))
    }
}

struct LoadingSymbol_Previews: PreviewProvider {
    static var previews: some View {
        LoadingSymbol()
            .preferredColorScheme(.dark)
        LoadingSymbol()
    }
}
