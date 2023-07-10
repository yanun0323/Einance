import Ditto
import SwiftUI

struct CardContent: View {
    @Environment(\.injected) private var container
    @State private var main: FinanceCategory
    @State private var secondary: FinanceCategory
    @ObservedObject var card: Card
    private var isPreview: Bool

    init(inject: DIContainer, card: Card, isPreview: Bool = false) {
        self._main = .init(initialValue: inject.interactor.setting.GetCardBudgetCategoryAbove())
        self._secondary = .init(
            initialValue: inject.interactor.setting.GetCardBudgetCategoryBelow())
        self._card = .init(wrappedValue: card)
        self.isPreview = isPreview
    }

    var body: some View {
        VStack(spacing: isPreview ? 10 : 0) {
            title()
            if isPreview {
                preview()
            } else {
                values()
            }
        }
        .foregroundColor(isPreview ? .section : card.fColor)
        .onChange(of: main) { container.interactor.setting.SetCardBudgetCategoryAbove($0) }
        .onChange(of: secondary) { container.interactor.setting.SetCardBudgetCategoryBelow($0) }
        .onReceived(container.appstate.aboveBudgetCategoryPubliser) { if !isPreview { main = $0 } }
        .onReceived(container.appstate.belowBudgetCategoryPubliser) {
            if !isPreview { secondary = $0 }
        }
    }

    @ViewBuilder
    private func title() -> some View {
        HStack(spacing: 10) {
            if card.isForever {
                Image(systemName: "pin.fill")
                    .rotationEffect(.degrees(45))
                    .font(.system(size: 20, weight: .medium))
            }
            Text(card.name)
                .font(.system(size: 40, weight: .medium))
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            Spacer()

            Block(width: 40, height: 40)
        }
    }

    @ViewBuilder
    private func preview() -> some View {
        HStack(spacing: 15) {
            previewCategoryLabel($main)
            previewCategoryLabel($secondary)
            Spacer()
        }
    }

    @ViewBuilder
    private func values() -> some View {
        HStack(spacing: 10) {
            Text(main.value(card).description)
            Text(secondary.value(card).description)
                .opacity(0.2)
            Spacer()
        }
        .font(.system(size: 40, weight: .medium, design: .rounded))
    }

    @ViewBuilder
    private func previewCategoryLabel(_ category: Binding<FinanceCategory>) -> some View {
        Menu {
            Picker("", selection: category) {
                ForEach(FinanceCategory.allCases) { c in
                    if c != .none {
                        Text(c.label()).tag(c)
                    }
                }
            }
        } label: {
            Text(category.wrappedValue.label())
                .font(.system(size: 20, weight: .regular, design: .rounded))
                .kerning(2)
                .foregroundColor(card.bColor)
                .frame(width: 100, height: 35)
                .backgroundColor(.section.opacity(0.5))
                .cornerRadius(5)
        }
    }
}

struct CardContent_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CardContent(inject: .preview, card: .preview)
                .background(Color.gray)
            CardContent(inject: .preview, card: .preview, isPreview: true)
                .padding()
                .background(Color.section)
        }
    }
}
