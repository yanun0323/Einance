import SwiftUI
import UIComponent

struct SettingView: View {
    @EnvironmentObject private var container: DIContainer
    @State private var aboveBudgetCategory: BudgetCategory = .Cost
    @State private var belowBudgetCategory: BudgetCategory = .Amount
    @State private var appearance: ColorScheme? = nil
    @State private var color: Color
    
    @State private var showDateNumberAlert: Bool = false
    @State private var dateNumberEdit: Int
    @State private var dateNumber: Int
    
    @State private var showDangerAlert: Bool = false
    @State private var dangerAlertTitle: LocalizedStringKey = ""
    @State private var dangerAction: () -> Void = {}
    
    @ObservedObject var budget: Budget
    @ObservedObject var current: Card
    
    init(injector: DIContainer, budget: Budget, current: Card) {
        self._budget = .init(wrappedValue: budget)
        self._current = .init(wrappedValue: current)
        self._color = .init(initialValue: current.color)
        self._appearance = .init(initialValue: injector.interactor.setting.GetAppearance())
        let dateNumber = injector.interactor.setting.GetBaseDateNumber()
        self._dateNumber = .init(initialValue: dateNumber)
        self._dateNumberEdit = .init(initialValue: dateNumber)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ViewHeader(title: "view.header.setting")
                .padding(.horizontal)
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 30) {
                    _AppearanceBlock
                    _DashboardStyleSample
                    _CardShapeStyleSample
                    _BaseNumberBlock
                    _DangerZoneBlock
                    Spacer()
                }
            }
            .frame(width: System.device.screen.width - 30)
        }
        .background(Color.background)
        .animation(.medium, value: dateNumberEdit)
        .transition(.scale(scale: 0.95, anchor: .topLeading).combined(with: .opacity))
        .alert("確定要變更更新日期？", isPresented: $showDateNumberAlert, actions: {
            _DateNumberAlertButton
        }, message: {
            Text("下次更新日期")+Text(" ")+Text(_CalculateNextDate().String("yyyy.MM.dd"))
                .kerning(1)
        })
        .alert(dangerAlertTitle, isPresented: $showDangerAlert, actions: {
            Button("global.confirm", role: .destructive, action: dangerAction)
        })
    }
}

// MARK: - ViewBlock
extension SettingView {
    
    var _BaseNumberBlock: some View {
        VStack(alignment: .leading, spacing: 5) {
            if dateNumberEdit != 0 {
                Text("更新日期")
                    .foregroundColor(.primary25)
                    .font(.caption)
                    .padding(.leading)
                RoundedRectangle(cornerRadius: Setting.globalCornerRadius)
                    .foregroundColor(.section)
                    .frame(height: isDateNumberChanged ? 200: 160)
                    .overlay {
                        VStack(spacing: 0) {
                            _BaseNumberContentEdit
                            Spacer()
                        }
                    }
            }
        }
    }
    
    var _BaseNumberContentEdit: some View {
        ZStack {
            HStack(spacing: 20) {
                ButtonCustom(width: 100, height: 33, color: .section.opacity(0.5), radius: 5, shadow: 5) {
                    withAnimation(.quick) {
                        dateNumberEdit = dateNumber
                    }
                } content: {
                    Text("global.cancel")
                }
                
                ButtonCustom(width: 100, height: 33, color: color, radius: 5) {
                    withAnimation(.quick) {
                        showDateNumberAlert = true
                    }
                } content: {
                    Text("global.change")
                        .foregroundColor(.white)
                }
            }
            .scaleEffect(y: isDateNumberChanged ? 1 : 0.2, anchor: .top)
            .offset(y: 95)
            .opacity(isDateNumberChanged ? 1 : 0)
            .disabled(!isDateNumberChanged)
            
            VStack {
                HStack {
                    Text("welcome.step.1.picker.left")
                    Picker("", selection: $dateNumberEdit) {
                        ForEach(1...31, id: \.self) { i in
                            Text(i.description)
                                .tag(i)
                                .foregroundColor(color)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 80, height: 100)
                    Text("welcome.step.1.picker.right")
                }
                
                VStack {
                    HStack(spacing: 10) {
                        Text("上次更新日期")
                        Text(budget.startAt.String("yyyy.MM.dd"))
                            .kerning(1)
                    }
                    HStack(spacing: 10) {
                        Text("下次更新日期")
                        Text(_CalculateNextDate().String("yyyy.MM.dd"))
                            .kerning(1)

                    }
                    .foregroundColor(isDateNumberChanged ? color : .gray)
                    .fontWeight(isDateNumberChanged ? .regular : .light)
                    .animation(.quick, value: isDateNumberChanged)
                    .animation(.none, value: dateNumberEdit)
                }
                .font(.caption)
                .fontWeight(.light)
                .foregroundColor(.gray)
                .monospacedDigit()
            }
            .frame(height: 150)
        }
    }
    
    var _DateNumberAlertButton: some View {
        Button("global.change", role: .destructive) {
            withAnimation(.medium) {
                dateNumber = dateNumberEdit
                container.interactor.setting.SetBaseDateNumber(dateNumber)
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
    
    var _DangerZoneBlock: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("危險區域")
                .foregroundColor(.red)
                .font(.caption)
                .padding(.leading)
            RoundedRectangle(cornerRadius: Setting.globalCornerRadius)
                .foregroundColor(.red.opacity(0.1))
                .frame(height: 100)
                .overlay {
                    VStack(spacing: 0) {
                        Spacer()
                        _DangerForceUpdateBudgetButton
                        Spacer()
                    }
                }
        }
    }
    
    var _DangerForceUpdateBudgetButton: some View {
        Button {
            withAnimation(.quick) {
                dangerAlertTitle = "確定要強制更新卡片到下個月?"
                dangerAction = {
                    container.interactor.data.UpdateMonthlyBudget(budget, force: true)
                }
                showDangerAlert = true
            }
        } label: {
            Text("強制更新卡片到下個月")
                .font(.body)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 7)
        .backgroundColor(.red)
        .cornerRadius(7)


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
    
    var isDateNumberChanged: Bool {
        dateNumber != dateNumberEdit
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
    
    func _CalculateNextDate() -> Date {
        let nextDay1 = budget.startAt.AddMonth(1).firstDayOfMonth
        if nextDay1.daysOfMonth < dateNumberEdit {
            return nextDay1.AddMonth(1).AddDay(-1)
        }
        return nextDay1.AddDay(dateNumberEdit-1)
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView(injector: .preview, budget: .preview, current: .preview)
            .inject(DIContainer.preview)
        SettingView(injector: .preview, budget: .preview, current: .preview)
            .inject(DIContainer.preview)
            .preferredColorScheme(.dark)
    }
}
