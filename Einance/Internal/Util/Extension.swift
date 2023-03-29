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
            .backgroundColor(.backgroundButton, ignoresSafeAreaEdges: .bottom)
            .clipShape(RoundedRectangle(cornerRadius: Setting.panelCornerRadius))
            .shadow(radius: 5)
    }
    
    func modifyRouterBackground() -> some View {
        self
            .padding(.horizontal)
            .backgroundColor(.background, ignoresSafeAreaEdges: .bottom)
    }
    
    func backgroundColor(_ color: Color, ignoresSafeAreaEdges edges: Edge.Set = []) -> some View {
        self.background(color, ignoresSafeAreaEdges: edges)
    }
}

extension Animation {
    static var shoot: Animation = .easeInOut(duration: 0.1)
    static var quick: Animation = .easeInOut(duration: 0.2)
    static var medium: Animation = .easeInOut(duration: 0.6)
    static var slow: Animation = .easeInOut(duration: 1)
}

extension View {
    func onReceived<P>(animation: Animation = .quick, _ publisher: P, perform action: @escaping (P.Output) -> Void) -> some View where P : Publisher, P.Failure == Never {
        withAnimation(animation) {
            self.onReceive(publisher, perform: action)
        }
    }
    
    func onReceived<P>(animation: Animation = .quick, _ publisher: P, perform action: @escaping () -> Void) -> some View where P : Publisher, P.Failure == Never {
        withAnimation(animation) {
            self.onReceive(publisher, perform: { _ in action() })
        }
    }
    
    func onChanged<V>(_ animation: Animation = .quick, of value: V, perform action: @escaping (_ newValue: V) -> Void) -> some View where V : Equatable {
        withAnimation(animation) {
            self.onChange(of: value, perform: action)
        }
    }
    
    func onChanged<V>(_ animation: Animation = .quick, of value: V, perform action: @escaping () -> Void) -> some View where V : Equatable {
        withAnimation(animation) {
            self.onChange(of: value, perform: { _ in action() })
        }
    }
    
    func onAppeared(_ animation: Animation = .quick, perform action: (() -> Void)?) -> some View {
        withAnimation(animation) {
            self.onAppear(perform: action)
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
