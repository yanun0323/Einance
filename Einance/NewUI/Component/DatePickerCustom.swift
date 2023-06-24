import SwiftUI
import Ditto

struct DatePickerCustom<S>: View where S : DatePickerStyle {
    @Binding var datePicked: Date
    var start: Date
    var end: Date?
    var style: S
    var component: DatePickerComponents? = nil
    var cancelAction: () -> Void

    var body: some View {
        HalfSheet(grabber: false) {
            GeometryReader { bounds in
                VStack(alignment: .center, spacing: 0) {
                    headerBlock()
                        .padding([.horizontal, .top])
                    Spacer()
                    pickerBlock()
                    .padding(.horizontal)
                    .frame(width: bounds.size.width*0.9)
                    Spacer()
                }
            }
        }
    }
    
    @ViewBuilder
    private func headerBlock() -> some View {
        HStack {
            Block(width: 30, height: 10)
            Spacer()
            Text("日期")
                .font(.title3)
            Spacer()
            Image(systemName: "multiply.circle.fill")
                .foregroundColor(.primary25)
                .font(.title)
                .onTapGesture { cancelAction() }
        }
    }
    
    @ViewBuilder
    private func pickerBlock() -> some View {
        VStack {
            if let end = end {
                if let comp = component {
                    DatePicker("", selection: $datePicked, in: start...end, displayedComponents: comp)
                        .labelsHidden()
                        .monospacedDigit()
                        .datePickerStyle(style)
                } else {
                    DatePicker("", selection: $datePicked, in: start...end)
                        .labelsHidden()
                        .monospacedDigit()
                        .datePickerStyle(style)
                }
            } else {
                if let comp = component {
                    DatePicker("", selection: $datePicked, in: start..., displayedComponents: comp)
                        .labelsHidden()
                        .monospacedDigit()
                        .datePickerStyle(style)
                } else {
                    DatePicker("", selection: $datePicked, in: start...)
                        .labelsHidden()
                        .monospacedDigit()
                        .datePickerStyle(style)
                    
                }
            }
        }
    }
    
}

#if DEBUG
struct DatePickerCustom_Previews: PreviewProvider {
    static var previews: some View {
        DatePickerCustom(datePicked: .constant(Date.now), start: Date.now, end: nil, style: .graphical) {
            print("Hello")
        }
    }
}
#endif

public enum HalfSheetStyle {
    case medium, large
}

// MARK: Controller
public class HalfSheetController<Content>: UIHostingController<Content> where Content: View {
    public var grabber: Bool = true
    public var radius: CGFloat = 15
    public var detents: [UISheetPresentationController.Detent] = []
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let presentation = sheetPresentationController {
            presentation.detents = detents  // [.medium(), .large()]
            presentation.prefersGrabberVisible = grabber
            presentation.largestUndimmedDetentIdentifier = .medium
            presentation.preferredCornerRadius = radius
        }
    }
    
    public func Inject(
        _ grabberVisible: Bool, _ cornerRadius: CGFloat, _ style: [HalfSheetStyle]
    ) -> Self {
        self.grabber = grabberVisible
        self.radius = cornerRadius
        style.forEach { s in
            switch s {
                case .medium:
                    self.detents.append(.medium())
                case .large:
                    self.detents.append(.large())
                    
            }
        }
        return self
    }
}

// MARK: Structure
public struct HalfSheet<Content>: UIViewControllerRepresentable where Content: View {
    
    public let grabber: Bool
    public let radius: CGFloat
    public let style: [HalfSheetStyle]
    public let content: Content
    
    public init(
        grabber: Bool = true, radius: CGFloat = 15, style: [HalfSheetStyle] = [.medium],
        @ViewBuilder content: () -> Content
    ) {
        self.grabber = grabber
        self.radius = radius
        self.style = style
        self.content = content()
    }
    
    public func makeUIViewController(context: Context) -> HalfSheetController<Content> {
        return HalfSheetController(rootView: content).Inject(grabber, radius, style)
    }
    
    public func updateUIViewController(_: HalfSheetController<Content>, context: Context) {
    }
}
