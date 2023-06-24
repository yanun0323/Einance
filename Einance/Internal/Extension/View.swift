import SwiftUI
import Combine

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
    
    func barSheet(isPresented: Binding<Bool>, includeHalf half: Bool = false, onDismiss dismiss: (() -> Void)? = nil,  content view: @escaping () -> some View) -> some View {
        self
            .sheet(isPresented: isPresented, onDismiss: dismiss) {
                view()
                    .presentationDetents(half ? [.large, .medium] : [.large])
                    .presentationDragIndicator(.visible)
            }
    }
    
    @ViewBuilder
    static func sheetWrapper(title: LocalizedStringKey, fColor: Color, colors: [Color], contnet view: @escaping () -> some View) -> some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    Text(title)
                        .font(Setting.panelTitleFont)
                        .foregroundColor(fColor)
                        .padding(.vertical, 30)
                    Spacer()
                }
                Spacer()
            }
            .backgroundLinearGradient(colors)
            RoundedRectangle(cornerRadius: 30)
                .blendMode(.destinationOut)
                .overlay {
                    view()
                        .padding([.horizontal, .top], 30)
                }
                .padding(.top, 80)
                .ignoresSafeArea(.all, edges: .bottom)
            
        }
        .compositingGroup()
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
    @State var valueChangedFromOutside: Bool = false
    var body: some View {
        Button {
            showSheet = true
        } label: {
            Text("SHOW: \(valueChangedFromOutside ? "A" : "B")")
        }
        .barSheet(isPresented: $showSheet) {
            valueChangedFromOutside.toggle()
        } content: {
            ZStack {
                Color.red.ignoresSafeArea(.all)
                Button {
                    showSheet = false
                } label: {
                    Text("CLOSE")
                }
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
