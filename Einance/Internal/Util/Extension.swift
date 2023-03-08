import SwiftUI
import UIComponent

extension View {
    func previewDeviceSet() -> some View {
        Group {
            self.previewDevice(PreviewDevice(rawValue: "iPhone 12 mini"))
                .previewDisplayName("iPhone 12 mini")
            self.previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro"))
                .previewDisplayName("iPhone 13 Pro")
            self.previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
                .previewDisplayName("iPhone 14 Pro")
        }
    }
    
    func modifyPanelBackground() -> some View {
        self
            .monospacedDigit()
            .backgroundColor(.background)
            .clipShape(RoundedRectangle(cornerRadius: Setting.panelCornerRadius))
            .shadow(radius: 5)
    }
    
    func backgroundColor(_ color: Color) -> some View {
        self.background(color)
    }
}

extension Animation {
    static var shoot: Animation = .easeInOut(duration: 0.1)
    static var quick: Animation = .easeInOut(duration: 0.2)
    static var medium: Animation = .easeInOut(duration: 0.6)
    static var slow: Animation = .easeInOut(duration: 1)
}

extension Color {
    static var background: Color = .init("Background")
}

extension Date {
    static var zero: Date = .init(timeIntervalSince1970: 0)
}

extension System {
    static func Catch<T>(_ log: String, _ action: () throws -> T?) -> T? where T: Any {
        do {
            return try action()
        } catch {
            print("[ERROR] \(log) failed, err: \(error)")
        }
        return nil
    }
}
