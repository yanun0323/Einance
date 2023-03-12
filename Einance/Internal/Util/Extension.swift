import SwiftUI
import UIComponent
import Combine

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
            .backgroundColor(.backgroundButton)
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

extension View {
    func onQuickRecive<P>(_ publisher: P, perform action: @escaping (P.Output) -> Void) -> some View where P : Publisher, P.Failure == Never {
        onSmoothRecive(.quick, publisher, perform: action)
    }
    
    func onSmoothRecive<P>(_ animation: Animation, _ publisher: P, perform action: @escaping (P.Output) -> Void) -> some View where P : Publisher, P.Failure == Never  {
        withAnimation(animation) {
            self.onReceive(publisher, perform: action)
        }
    }
}

extension Color {
    static var background: Color = .init("Background")
    static var backgroundButton: Color = .init("BackgroundButton")
}

extension Date {
    static var zero: Date = .init(timeIntervalSince1970: 0)
    var key: Date {
        return Date(from: self.String(.Numeric), .Numeric) ?? .zero
    }
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
