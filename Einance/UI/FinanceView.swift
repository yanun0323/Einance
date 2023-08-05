import SwiftUI
import Ditto

struct FinanceView: View {
    @Environment(\.injected) private var container
    @StateObject private var budget = Budget.preview
    @State private var selected = Card.preview
    
    private let cardRatio = CGFloat(0.9)
    private let cardSpacing = CGFloat(0.02)
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Block(size: .statusbar)
                containerView()
                    .frame(size: .container)
                Block(size: .homebar)
            }
            .debug(cover: .device)
            .ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    private func containerView() -> some View {
        VStack(spacing: 0) {
            headerView()
                .frame(size: .header)
                .debug(.purple)
            dashboardView()
                .frame(size: .dashboard)
                .debug(.green)
            collectionView()
                .frame(size: .collection)
                .debug(.blue)
            listView()
                .frame(size: .list)
                .debug(.mint)
        }
    }
    
    @ViewBuilder
    private func headerView() -> some View {
        HStack(spacing: 0) {
            Text("\(selected.name)")
        }
    }
    
    @ViewBuilder
    private func dashboardView() -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 0) {
                Text("10200")
                Spacer()
                Text("500")
            }
            .font(.system(size: 36, weight: .medium))
            .monospacedDigit()
            RoundedRectangle(cornerRadius: .buttonRadius)
                .foregroundColor(.section)
                .frame(height: .barHeight)
        }
        .padding(.horizontal, .deviceMargin)
    }
    
    @ViewBuilder
    private func collectionView() -> some View {
        TabView(selection: $selected) {
            ForEach(budget.book.indices, id: \.self) { i in
                let card = budget.book[i]
                CardView(budget: budget, card: card)
                    .frame(size: .collection)
                    .tag(card)
                    .background {
                        if i < budget.book.count-1 {
                            CardView(budget: budget ,card: budget.book[i+1])
                                .offset(x: CGSize.collection.width * (card == selected ? cardRatio + cardSpacing : 1))
                        }

                        if i > 0 {
                            CardView(budget: budget, card: budget.book[i-1])
                                .offset(x: -CGSize.collection.width * (card == selected ? cardRatio + cardSpacing : 1))
                        }
                    }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeOut(duration: 0.2), value: selected)
        .scaledToFill()
    }
    
    @ViewBuilder
    private func listView() -> some View {
        ScrollViewReader { proxy in
            List {
                EmptyView().id("top")
                if selected.pinnedArray.count != 0 {
                    detailSection(
                        "panel.record.create.pinned.label", selected.pinnedArray, selected.pinnedCost)
                    .debug(.purple)
                }
                ForEach(selected.dateDict.keys.elements.reversed(), id: \.self) { k in
                    let title = k.string("yyyy.MM.dd EE")
                    detailSection(title, selected.dateDict[k]!.records, selected.dateDict[k]!.cost)
                        .debug(.orange)
                }
                Block(height: 100)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .font(.system(size: 20, weight: .regular))
            .monospacedDigit()
            .onChanged(of: selected) { proxy.scrollTo("top") }
        }
        .padding(.horizontal)
        .scrollIndicators(.hidden)
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
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        withAnimation(.quick) {
                            container.interactor.data.DeleteRecord(budget, selected, r)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }

                    Button(role: .none) {
                        container.interactor.system.PushActionView(.EditRecord(budget, selected, r))
                    } label: {
                        Label("Edit", systemImage: "square.and.pencil")
                    }
                }
                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                    if selected.pinned {
                        Button(role: .cancel) {
                            withAnimation(.quick) {
                                let pinned = !r.pinned
                                container.interactor.data.UpdateRecord(
                                    budget, selected, r, date: r.date, cost: r.cost, memo: r.memo,
                                    pinned: pinned)
                            }
                        } label: {
                            Label("Fixed", systemImage: "pin")
                        }
                    }
                }
                .opacity(0.3)
                .fontWeight(.regular)
                .padding(.leading)
                .padding(.horizontal)
            }
        } header: {
            HStack {
                Text(LocalizedStringKey(title))
                    .font(.system(size: 26, weight: .medium))
                    .foregroundLinearGradient(selected.bgColor)
                    .monospacedDigit()
                Spacer()
                Text("\(sum.description) $")
                    .font(.system(size: 22, weight: .regular))
                    .opacity(0.7)

            }
            .padding(.horizontal)
            .background()
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 0, leading: -16, bottom: 0, trailing: -16))
        .padding(.horizontal)
        .listRowSeparator(.hidden)
        .listSectionSeparator(.hidden)
    }
    
}

struct FinanceView_Previews: PreviewProvider {
    static var previews: some View {
        FinanceView()
            .inject(.preview)
            .environment(\.locale, .us)
    }
}
