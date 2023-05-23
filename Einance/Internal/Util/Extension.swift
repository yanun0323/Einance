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
    
    func barSheet<Content>(isPresented: Binding<Bool>, includeHalf half: Bool = false, onDismiss dismiss: (() -> Void)? = nil,  content view: @escaping () -> Content) -> some View where Content: View {
        self
            .sheet(isPresented: isPresented, onDismiss: dismiss) {
                view()
                    .padding(.top)
                    .presentationDetents(half ? [.large, .medium] : [.large])
                    .presentationDragIndicator(.visible)
            }
    }
    
    func modifyPanelBackground() -> some View {
        self
            .monospacedDigit()
            .padding()
    }
    
    func modifyRouterBackground() -> some View {
        self
            .monospacedDigit()
            .backgroundColor(.clear, ignoresSafeAreaEdges: .bottom)
    }
    
    func backgroundColor(_ color: Color, ignoresSafeAreaEdges edges: Edge.Set = []) -> some View {
        self.background(color, ignoresSafeAreaEdges: edges)
    }
    
    func clippedShadow(_ shadow: Color = .black.opacity(0.2), blur: CGFloat = 5, radius: CGFloat = 20, height: CGFloat, y: CGFloat = 10) -> some View {
        ZStack {
            shadow
                .frame(height: height)
                .cornerRadius(radius*0.8)
                .offset(y: y)
                .blur(radius: blur)
            RoundedRectangle(cornerRadius: radius)
                .frame(height: height)
                .blendMode(.destinationOut)
            self
        }
        .compositingGroup()
    }
}

#if DEBUG
struct ExtensionView: View {
    @State var showSheet: Bool = true
    @State var trigger: Bool = false
    var body: some View {
        Button {
            showSheet = true
        } label: {
            Text("SHOW: \(trigger ? "A" : "B")")
        }
        .barSheet(isPresented: $showSheet) {
            trigger.toggle()
        } content: {
            Button {
                showSheet = false
            } label: {
                Text("CLOSE")
            }
        }
    }
}

struct Extension_Previews: PreviewProvider {
    static var previews: some View {
        ExtensionView()
    }
}
#endif

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
    
    var in24H : Int {
        return self.unix%86400
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
    
    static func device(with padding: CGFloat) -> CGRect {
        let d = Self.device.screen
        return CGRect(x: d.minX, y: d.minY, width: d.width - 2*padding, height: d.height - 2*padding)
    }
    
    static func square(with padding: CGFloat) -> CGRect {
        let d = Self.device.screen
        return CGRect(x: d.minX, y: d.minY, width: d.width - 2*padding, height: d.width - 2*padding)
    }
    
    static func screen(type: T = .height, ratio: CGFloat) -> (CGFloat) {
        return type == .width ? device.screen.width * ratio : device.screen.height * ratio
    }
}

extension System {
    enum T {
        case width, height
    }
}

extension TimeInterval {
    static var day: TimeInterval = 86400
    static var hour: TimeInterval = 3600
    static var minute: TimeInterval = 60
}

extension LocalizedStringKey {
    
    /**
     Return localized value of thisLocalizedStringKey
     */
    public var string: String {
        return ""
    }
}

extension String {
    var localizedKey: LocalizedStringKey {
        return .init(self)
    }
    
    var localized: String {
        return String(localized: LocalizedStringResource(stringLiteral: self))
    }
}

extension View {
    public func foregroundLinearGradient(_ colors: [Color], start: UnitPoint = .topLeading, end: UnitPoint = .trailing) -> some View {
        return self.overlay {
            LinearGradient(colors: colors, startPoint: start, endPoint: end)
                .mask { self }
        }
    }
    
    public func backgroundLinearGradient(_ colors: [Color], start: UnitPoint = .topLeading, end: UnitPoint = .trailing) -> some View {
        return self.background(
            LinearGradient(colors: colors, startPoint: start, endPoint: end)
        )
    }
}
