import SwiftUI
import UIComponent

struct SettingView: View {
    @EnvironmentObject private var container: DIContainer
    @State private var aboveBudgetCategory: BudgetCategory = .Cost
    @State private var belowBudgetCategory: BudgetCategory = .Amount
    @State private var appearance: ColorScheme? = nil
    
    @ObservedObject var budget: Budget
    @ObservedObject var current: Card
    
    private let color: Color = .primary
    
    var body: some View {
        VStack(spacing: 0) {
            ViewHeader(title: "設定")
                .padding(.horizontal)
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 30) {
                    _AppearanceBlock
                    _DashboardStyleSample
                    _CardShapeStyleSample
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .background(Color.background)
        .onAppear {
            appearance = container.interactor.setting.GetAppearance()
        }
    }
}

// MARK: - ViewBlock
extension SettingView {
    
    var _DashboardStyleSample: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("儀表板樣式")
                .foregroundColor(.primary25)
                .font(.caption)
                .padding(.leading)
            RoundedRectangle(cornerRadius: Setting.globalCornerRadius)
                .foregroundColor(.section)
                .frame(height: 120)
                .overlay {
                    Dashboard(budget: budget, current: current, isPreview: true, previewColor: color)
                        .padding(.horizontal)
                }
        }
    }
    
    var _CardShapeStyleSample: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("卡片樣式")
                .foregroundColor(.primary25)
                .font(.caption)
                .padding(.leading)
            CardRect(budget: budget, card: current, isPreview: true, previewColor: color)
                .frame(
                    width: widthWithPadding,
                    height: widthWithPadding*0.66
                )
        }
    }
    
    var _AppearanceBlock: some View {
        VStack(spacing: 5) {
            Section {
                RoundedRectangle(cornerRadius: Setting.globalCornerRadius)
                    .frame(height: 250)
                    .foregroundColor(.section)
                    .overlay {
                        HStack(spacing: 0) {
                            Spacer()
                            ButtonCustom(width: 80, height: 200) {
                                withAnimation(.quick) {
                                    appearance = nil
                                    container.interactor.setting.SetAppearance(nil)
                                }
                            } content: {
                                _ScreenSystem
                            }
                            
                            Spacer()
                            ButtonCustom(width: 80, height: 200) {
                                withAnimation(.quick) {
                                    appearance = .light
                                    container.interactor.setting.SetAppearance(.light)
                                }
                            } content: {
                                _ScreenLight
                            }
                            Spacer()
                            ButtonCustom(width: 80, height: 200) {
                                withAnimation(.quick) {
                                    appearance = .dark
                                    container.interactor.setting.SetAppearance(.dark)
                                }
                            } content: {
                                _ScreenDark
                            }
                            Spacer()
                        }
                    }
            } header: {
                HStack {
                    Text("APP 外觀")
                        .foregroundColor(.primary50)
                        .font(.caption)
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
    }
    
    var _ScreenSystem: some View {
        VStack {
            ZStack {
                _AppearanceImage(.light)
                    .mask {
                        HStack {
                            Rectangle()
                                .frame(width: 30)
                            Spacer()
                        }
                    }
                _AppearanceImage(.dark)
                    .mask {
                        HStack {
                            Spacer()
                            Rectangle()
                                .frame(width: 30)
                        }
                    }
            }
            .cornerRadius(10, antialiased: true)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(color, style: StrokeStyle(lineWidth: 3))
                    .opacity(appearance == nil ? 1 : 0)
            )
            Text("系統")
            Block(width: 5, height: 5)
            ZStack {
                Image(systemName: "circle")
                    .foregroundColor(.primary50)
                    .font(.title3)
                if appearance == nil {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(color)
                        .font(.title3)
                }
            }
        }
    }
    
    var _ScreenLight: some View {
        VStack {
            _AppearanceImage(.light)
                .cornerRadius(10, antialiased: true)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(color, style: StrokeStyle(lineWidth: 3))
                        .opacity(appearance == .light ? 1 : 0)
                )
            Text("淺色")
            Block(width: 5, height: 5)
            ZStack {
                Image(systemName: "circle")
                    .foregroundColor(.primary50)
                    .font(.title3)
                if appearance == .light {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(color)
                        .font(.title3)
                }
            }
        }
    }
    
    var _ScreenDark: some View {
        VStack {
            _AppearanceImage(.dark)
                .cornerRadius(10, antialiased: true)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(color, style: StrokeStyle(lineWidth: 3))
                        .opacity(appearance == .dark ? 1 : 0)
                )
            Text("深色")
            Block(width: 5, height: 5)
            ZStack {
                Image(systemName: "circle")
                    .foregroundColor(.primary50)
                    .font(.title3)
                if appearance == .dark {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(color)
                        .font(.title3)
                }
            }
        }
    }
    
}

// MARK: - Property
extension SettingView {
//    var window: UIWindow? {
//        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first
//    }
    
    var widthWithPadding: CGFloat {
        System.device.screen.width-30
    }
}

// MARK: - Function
extension SettingView {
    func _AppearanceImage(_ theme: ColorScheme) -> some View {
        ZStack {
            Image(theme == .dark ? "ScreenDark" : "ScreenLight")
                .resizable()
                .frame(width: 60, height: 120)
                .blur(radius: 0.5, opaque: false)
            VStack(spacing: 5) {
                Text(Date.now.String("HH:mm"))
                    .foregroundColor(.white)
                RoundedRectangle(cornerRadius: 3)
                    .foregroundColor(_AppearanceColor(theme))
                    .frame(width: 50, height: 16)
                    .opacity(0.8)
                RoundedRectangle(cornerRadius: 3)
                    .foregroundColor(_AppearanceColor(theme))
                    .frame(width: 50, height: 16)
                    .opacity(0.8)
            }
        }
    }
    
    func _AppearanceColor(_ theme: ColorScheme) -> Color {
        let light = 0.8
        let dark = 0.2
        switch theme {
            case .light:
                return Color(red: light, green: light ,blue: light)
            case .dark:
                return Color(red: dark, green: dark ,blue: dark)
            @unknown default:
                return Color(red: light, green: light ,blue: light)
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView(budget: .preview, current: .preview)
            .inject(DIContainer.preview)
        SettingView(budget: .preview, current: .preview)
            .inject(DIContainer.preview)
            .preferredColorScheme(.dark)
    }
}
