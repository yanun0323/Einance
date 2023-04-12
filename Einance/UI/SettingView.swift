import SwiftUI
import UIComponent

struct SettingView: View {
    @EnvironmentObject private var container: DIContainer
    @State private var aboveBudgetCategory: BudgetCategory = .Cost
    @State private var belowBudgetCategory: BudgetCategory = .Amount
    @State private var appearance: ColorScheme? = nil
    @State private var locale: Locale
    @State private var color: Color
    
    @State private var showDateNumberAlert: Bool = false
    @State private var dateNumberEdit: Int
    @State private var dateNumber: Int
    @State private var calculatedNextDate: Date
    
    @State private var showDangerAlert: Bool = false
    @State private var dangerAlertTitle: LocalizedStringKey = ""
    @State private var dangerAction: () -> Void = {}
    
    @State private var forceUpdateFailed: Bool = false
    
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
        self._locale = .init(initialValue: injector.interactor.setting.GetLocale())
        let nextDate = injector.interactor.CalculateNextDate(budget.startAt, days: dateNumber)
        self._calculatedNextDate = .init(initialValue: nextDate)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ViewHeader(title: "view.header.setting")
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 30) {
                    appearanceBlock()
                    localeBlock()
                    dashboardStyleSample()
                    cardShapeStyleSample()
                    baseNumberBlock()
                    dangerZoneBlock()
                    Spacer()
                }
            }
            .frame(width: System.device.screen.width - 30)
        }
        .modifyRouterBackground()
        .animation(.medium, value: dateNumberEdit)
        .transition(.scale(scale: 0.95, anchor: .topLeading).combined(with: .opacity))
        .alert("setting.update_date.check", isPresented: $showDateNumberAlert) {
            dateNumberAlertButton()
        } message: {
            Text("setting.update_date.next")+Text(" ")+Text(calculatedNextDate.String("yyyy.MM.dd"))
                .kerning(1)
        }
        .alert(dangerAlertTitle, isPresented: $showDangerAlert) {
            Button("global.confirm", role: .destructive, action: dangerAction)
        }
        .alert("setting.update_date.udpated", isPresented: $forceUpdateFailed) {}
        .onChanged(of: locale) { container.interactor.setting.SetLocale($0) }
        .onChanged(of: dateNumberEdit) { calculatedNextDate = container.interactor.CalculateNextDate(budget.startAt, days: $0) }
    }
    
    @ViewBuilder
    private func localeBlock() -> some View {
        settingSection("setting.locale.label") {
            Menu {
                Picker(selection: $locale) {
                    Text("setting.locale.system").tag(Locale.current)
                    Text("setting.locale.tw").tag(Locale.TW)
                    Text("setting.locale.us").tag(Locale.US)
                } label: {}
            } label: {
                Text(getLocaleKey())
                    .font(.system(size: 20))
                    .frame(width: System.device.screen.size.width/2)
                    .foregroundColor(color)
                    .padding(5)
                    .animation(.none, value: locale)
                    .padding()
            }
        }
    }
    
    @ViewBuilder
    private func baseNumberBlock() -> some View {
        settingSection("setting.update_date.label") {
            VStack(spacing: 0) {
                baseNumberContentEdit()
                Spacer()
            }
            .frame(height: isDateNumberChanged() ? 200: 160)
        }
    }
    
    @ViewBuilder
    private func baseNumberContentEdit() -> some View {
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
            .scaleEffect(y: isDateNumberChanged() ? 1 : 0.2, anchor: .top)
            .offset(y: 95)
            .opacity(isDateNumberChanged() ? 1 : 0)
            .disabled(!isDateNumberChanged())
            
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
                        Text("setting.update_date.prevous")
                        Text(budget.startAt.String("yyyy.MM.dd"))
                            .kerning(1)
                    }
                    HStack(spacing: 10) {
                        Text("setting.update_date.next")
                        Text(calculatedNextDate.String("yyyy.MM.dd"))
                            .kerning(1)

                    }
                    .foregroundColor(isDateNumberChanged() ? color : .gray)
                    .fontWeight(isDateNumberChanged() ? .regular : .light)
                    .animation(.quick, value: isDateNumberChanged())
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
    
    @ViewBuilder
    private func dateNumberAlertButton() -> some View {
        Button("global.change", role: .destructive) {
            withAnimation(.medium) {
                dateNumber = dateNumberEdit
                container.interactor.setting.SetBaseDateNumber(dateNumber)
            }
        }
    }
    
    @ViewBuilder
    private func cardShapeStyleSample() -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("setting.card_style.label")
                .foregroundColor(.primary25)
                .font(.caption)
                .padding(.leading, 5)
            CardRect(budget: budget, card: current, isPreview: true, previewColor: color)
                .frame(
                    width: widthWithPadding(),
                    height: widthWithPadding()*0.66
                )
        }
    }
    
    @ViewBuilder
    private func dashboardStyleSample() -> some View {
        settingSection("setting.dashboard_style.label") {
            Dashboard(budget: budget, current: current, isPreview: true, previewColor: color)
                .padding()
        }
    }
    
    @ViewBuilder
    private func appearanceBlock() -> some View {
        settingSection("setting.appearance.label") {
            HStack(spacing: 0) {
                Spacer()
                ButtonCustom(width: 80, height: 200) {
                    withAnimation(.quick) {
                        appearance = nil
                        container.interactor.setting.SetAppearance(nil)
                    }
                } content: {
                    appearanceButtonLabel("setting.appearance.system", nil)
                }
                
                Spacer()
                ButtonCustom(width: 80, height: 200) {
                    withAnimation(.quick) {
                        appearance = .light
                        container.interactor.setting.SetAppearance(.light)
                    }
                } content: {
                    appearanceButtonLabel("setting.appearance.light", .light)
                }
                Spacer()
                ButtonCustom(width: 80, height: 200) {
                    withAnimation(.quick) {
                        appearance = .dark
                        container.interactor.setting.SetAppearance(.dark)
                    }
                } content: {
                    appearanceButtonLabel("setting.appearance.dark", .dark)
                }
                Spacer()
            }
            .padding(.vertical)
        }
    }
    
    @ViewBuilder
    private func dangerZoneBlock() -> some View {
        settingSection("setting.danger_zone.label", color: .red, bg: .red.opacity(0.1)) {
            VStack {
                dangerForceUpdateBudgetButton()
            }
            .padding(.vertical)
        }
    }
    
    @ViewBuilder
    private func dangerForceUpdateBudgetButton() -> some View {
        Button {
            withAnimation(.quick) {
                dangerAlertTitle = "setting.danger_zone.force_update_budget.check"
                dangerAction = {
                    forceUpdateFailed = !container.interactor.data.UpdateMonthlyBudget(budget, force: true)
                }
                showDangerAlert = true
            }
        } label: {
            Text("setting.danger_zone.force_update_budget")
                .font(.body)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 7)
        .backgroundColor(.red)
        .cornerRadius(7)
    }
    
    @ViewBuilder
    private func appearanceButtonLabel(_ title: LocalizedStringKey, _ scheme: ColorScheme?) -> some View {
        VStack {
            if let sc = scheme {
                appearanceImage(sc)
                    .cornerRadius(10, antialiased: true)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(color, style: StrokeStyle(lineWidth: 3))
                            .opacity(appearance == .light ? 1 : 0)
                    )
            } else {
                ZStack {
                    appearanceImage(.light)
                        .mask {
                            HStack {
                                Rectangle()
                                    .frame(width: 30)
                                Spacer()
                            }
                        }
                    appearanceImage(.dark)
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
            }
            
            Text(title)
            Block(width: 5, height: 5)
            ZStack {
                Image(systemName: "circle")
                    .foregroundColor(.primary50)
                    .font(.title3)
                if appearance == scheme {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(color)
                        .font(.title3)
                }
            }
        }
    }
    
    @ViewBuilder
    private func appearanceImage(_ theme: ColorScheme) -> some View {
        ZStack {
            Image(theme == .dark ? "ScreenDark" : "ScreenLight")
                .resizable()
                .frame(width: 60, height: 120)
                .blur(radius: 0.5, opaque: false)
            VStack(spacing: 5) {
                Text(Date.now.String("HH:mm"))
                    .foregroundColor(.white)
                RoundedRectangle(cornerRadius: 3)
                    .foregroundColor(appearanceColor(theme))
                    .frame(width: 50, height: 16)
                    .opacity(0.8)
                RoundedRectangle(cornerRadius: 3)
                    .foregroundColor(appearanceColor(theme))
                    .frame(width: 50, height: 16)
                    .opacity(0.8)
            }
        }
    }
    
    @ViewBuilder
    private func settingSection(_ title: LocalizedStringKey, color: Color = .primary25, bg: Color = .section, @ViewBuilder content: @escaping () -> some View) -> some View {
        SectionCustom(title, font: .caption, color: color, radius: Setting.globalCornerRadius, bg: bg) {
            HStack {
                Spacer()
                content()
                Spacer()
            }
        }
    }
}

// MARK: - Function
extension SettingView {
    
    private func widthWithPadding() -> CGFloat {
        System.device.screen.width-30
    }
    
    private func isDateNumberChanged() -> Bool {
        dateNumber != dateNumberEdit
    }
    
    private func appearanceColor(_ theme: ColorScheme) -> Color {
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
    
    private func getLocaleKey() -> LocalizedStringKey {
        switch locale {
            case .TW:
                return "setting.locale.tw"
            case .US:
                return "setting.locale.us"
            default:
                return "setting.locale.system"
        }
    }
    
}

#if DEBUG
struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView(injector: .preview, budget: .preview, current: .preview)
            .inject(DIContainer.preview)
            .environment(\.locale, .US)
        SettingView(injector: .preview, budget: .preview, current: .preview)
            .inject(DIContainer.preview)
            .preferredColorScheme(.dark)
    }
}
#endif
