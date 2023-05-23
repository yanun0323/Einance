import SwiftUI
import UIComponent

struct HomeViewV2: View {
    @EnvironmentObject private var container: DIContainer
    @State private var title: String? = nil
    @State private var debug: String = "-"
    @State private var accentColors: [Color] = [.cyan, Color(hex: "#2cc")]
    
    @ObservedObject var budget: Budget
    @ObservedObject var current: Card
    @Binding var selected: Card
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                dashboard()
                    .frame(height: System.screen(ratio: 0.12))
                cardVeiw()
            }
            .ignoresSafeArea(.all, edges: .bottom)
            adder()
        }
    }
    
    @ViewBuilder
    private func adder() -> some View {
        VStack {
            Spacer()
            HStack {
                Circle()
                    .frame(width: 80)
                    .foregroundLinearGradient(accentColors)
                    .shadow(radius: 5)
                    .overlay {
                        Image(systemName: "plus")
                            .font(.system(size: 45, weight: .light))
                            .foregroundColor(.white)
                    }
            }
            .font(.system(size: 20))
            .foregroundColor(.black.opacity(0.2))
        }
    }
    
    @ViewBuilder
    private func dashboard() -> some View {
        VStack(spacing: 5) {
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Overview")
                        .font(.system(size: 30, weight: .medium))
                        .foregroundLinearGradient(accentColors)
                    HStack(alignment: .bottom) {
                        Text("12200")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundLinearGradient(accentColors)
                        Text("30000")
                            .font(.system(size: 24, weight: .medium))
                            .opacity(0.3)
                    }
                    .monospacedDigit()
                }
                Spacer()
                HStack {
                    ButtonCustom(width: 50, height: 50) {
                        container.interactor.system.PushContentViewRouter(false)
                    } content: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }

                    Image(systemName: "line.3.horizontal")
                        .scaleEffect(y: 1.3)
                        .padding(.trailing, 5)
                }
                .font(.system(size: 30, weight: .light))
                .opacity(0.2)
            }
            HStack(spacing: 0) {
                Rectangle()
                    .foregroundLinearGradient(accentColors)
                Block()
            }
            .background(Color.section)
            .frame(height: 10)
            .cornerRadius(5)
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func cardVeiw() -> some View {
        ZStack {
            let radius: CGFloat = 30
            Rectangle()
                .foregroundColor(.transparent)
                .frame(height: System.screen(ratio: 0.77))
                .overlay {
                    VStack {
                        cardTab()
                        Spacer()
                    }
                    .foregroundColor(.white)
                    .monospacedDigit()
                }
                .backgroundLinearGradient(accentColors)
                .cornerRadius(radius)
            VStack {
                Spacer()
                RoundedRectangle(cornerRadius: radius)
                    .foregroundColor(.primary)
                    .frame(height: System.screen(ratio: 0.6))
                    .blendMode(.destinationOut)
                    .overlay {
                        detailList()
                    }
            }
        }
        .compositingGroup()
    }
    
    @ViewBuilder
    private func cardTabProto() -> some View {
        HStack {
            Text("Food")
                .font(.system(size: 40, weight: .medium))
            Spacer()
            Image(systemName: "pin.fill")
                .rotationEffect(.degrees(45))
                .font(.system(size: 20, weight: .medium))
        }
        HStack {
            Text("5120")
            Text("15000")
                .opacity(0.2)
            Spacer()
        }
        .font(.system(size: 40, weight: .medium, design: .rounded))
    }
    
    @ViewBuilder
    private func cardTab() -> some View {
        let cardHeight = System.screen(ratio: 0.22)
        ScrollView(.vertical, showsIndicators: false) {
            TabView(selection: $selected) {
                ForEach(budget.book) { card in
                    VStack {
                        HStack {
                            Text(card.name)
                                .font(.system(size: 40, weight: .medium))
                                .lineLimit(1)
                            if card.isForever {
                                Image(systemName: "pin.fill")
                                    .rotationEffect(.degrees(45))
                                    .font(.system(size: 20, weight: .medium))
                            }
                            Spacer()
                            Image(systemName: "ellipsis")
                                .rotationEffect(.degrees(90))
                                .font(.system(size: 28))
                        }
                        HStack {
                            Text(card.balance.description)
                            Text(card.amount.description)
                                .opacity(0.2)
                            Spacer()
                        }
                        .font(.system(size: 40, weight: .medium, design: .rounded))
                    }
                    .padding(.horizontal, 30)
                    .tag(card)
                }
            }
            .frame(height: cardHeight, alignment: .top)
            .offset(y: -System.screen(ratio: 0.025))
            .tabViewStyle(.page(indexDisplayMode: .always))
        }
        .ignoresSafeArea(.keyboard)
        .scrollDisabled(true)
    }
    
    @ViewBuilder
    private func detailListProto() -> some View {
        VStack {
            HStack {
                Text("Today")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundLinearGradient(accentColors)
                Spacer()
            }
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 10) {
                    ForEach(0...30, id: \.self) { i in
                        HStack {
                            Text(i%2 == 0 ? "Breakfast" : "Dinner")
                                .opacity(0.2)
                            Spacer()
                            Text("\(i)")
                                .opacity(0.7)
                                .font(.system(size: 22))
                            Text("$")
                                .opacity(0.2)
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .font(.system(size: 20, weight: .medium))
        .monospacedDigit()
        .padding(.horizontal, 30)
        .padding(.top, 20)
    }
    
    @ViewBuilder
    private func detailList() -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            let today = Date.now.String("yyyy.MM.dd")
            LazyVStack(spacing: 10, pinnedViews: [.sectionHeaders]) {
                if current.pinnedArray.count != 0 {
                    detailSection("Pinned", current.pinnedArray, current.pinnedCost)
                }
                ForEach(current.dateDict.keys.elements.reversed(), id: \.self) { k in
                    let title = k.String("yyyy.MM.dd")
                    detailSection(title == today ? "Today" : title, current.dateDict[k]!.records, current.dateDict[k]!.cost)
                }
            }
        }
        .font(.system(size: 20, weight: .medium))
        .monospacedDigit()
        .padding(.horizontal, 30)
        .padding(.top, 20)
    }
    
    @ViewBuilder
    private func detailSection(_ title: String, _ records: [Record], _ sum: Decimal) -> some View {
        Section {
            ForEach(records) { r in
                HStack {
                    Text(r.memo)
                        .kerning(1)
                    Spacer()
                    Text("\(r.cost.description) $")
                        .font(.system(size: 22))
                }
                .opacity(0.3)
                .fontWeight(.regular)
                .padding(.leading)
            }
        } header: {
            HStack {
                Text(LocalizedStringKey(title))
                    .font(.system(size: 30, weight: .medium))
                    .foregroundLinearGradient(accentColors)
                    .monospacedDigit()
                Spacer()
                Text("\(sum.description) $")
                    .font(.system(size: 22, weight: .regular))
                    .opacity(0.7)
                
            }
            .background(Color.background)
        }
    }
}

struct HomeViewV2_Previews: PreviewProvider {
    static var previews: some View {
        HomeViewV2(budget: .preview, current: .preview, selected: .constant(.preview))
            .inject(DIContainer.preview)
            .previewDeviceSet()
            .environment(\.locale, .US)
            .background(Color.background)
            .preferredColorScheme(.light)
    }
}
