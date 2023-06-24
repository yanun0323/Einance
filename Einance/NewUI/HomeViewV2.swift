import Ditto
import SwiftUI

struct HomeViewV2: View {
    @Environment(\.injected) private var container: DIContainer
    @State private var title: String? = nil
    @State private var debug: String = "-"
    @State private var bColor: Color = .cyan
    @State private var gColor: Color = Color(hex: "#2cc")
    @State private var showDeleteAlert = false
    @State private var showArchiveAlert = false

    @ObservedObject var budget: Budget
    @ObservedObject var current: Card
    @Binding var selected: Card

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    Spacer()
                    overview()
                        .ignoresSafeArea(.keyboard)
                        .padding(.horizontal)
                        .frame(height: System.screen(.height, 0.1))
                    dashboard()
                        .ignoresSafeArea(.keyboard)
                        .padding(.horizontal)
                        .frame(height: System.screen(.height, 0.1))
                    cardVeiw()
                        .ignoresSafeArea(.all, edges: .bottom)
                        .frame(height: System.screen(.height, 0.77))
                }
                .ignoresSafeArea(.all, edges: .bottom)
                .frame(size: System.screen)

                if !selected.isBlank {
                    adder()
                        .padding(.bottom, 30)
                        .frame(size: System.screen)
                        .ignoresSafeArea(.all)
                }
            }

        }
        .background(Color.background)
        .animation(.default, value: bColor)
        .animation(.default, value: gColor)
        .confirmationDialog(
            "card.context.alert.delete.title", isPresented: $showDeleteAlert,
            actions: {
                alertDeleteButton()
            },
            message: {
                Text("card.context.alert.delete.title")
            }
        )
        .confirmationDialog(
            "card.context.alert.archive.title", isPresented: $showArchiveAlert,
            actions: {
                alertArchiveButton()
            },
            message: {
                Text("card.context.alert.archive.title")
            }
        )
        .onAppeared { handleOnAppeared() }
        .onChanged(of: current) { handleOnAppeared() }
    }

    @ViewBuilder
    private func adder() -> some View {
        VStack(spacing: 0) {
            Spacer()
            Button(width: 80, height: 80) {
                container.interactor.system.PushActionView(.CreateRecord(budget, current))
            } content: {
                Image(systemName: "plus")
                    .font(.system(size: 45, weight: .light))
                    .foregroundColor(.white)
            }
            .backgroundLinearGradient([bColor, gColor])
            .mask {
                Circle()
            }
            .padding(.bottom, 1)
            .shadow(radius: 5)
        }
    }

    @ViewBuilder
    private func overview() -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("statistic.overview.lable")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundLinearGradient([bColor, gColor])

                Spacer()

                Button(width: 50, height: 50) {
                    container.interactor.system.PushActionView(.CreateCard(budget))
                } content: {
                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .light))
                        .opacity(0.2)
                }
                NavigationLink {
                    SettingRouterView(budget: budget, current: current)
                } label: {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 30, weight: .light))
                        .scaleEffect(y: 1.3)
                        .opacity(0.2)
                }
                .foregroundColor(.primary)
                .frame(width: 50, height: 50)
            }
        }
    }

    @ViewBuilder
    private func dashboard() -> some View {
        DashboardV2(budget: budget, current: current)
    }

    @ViewBuilder
    private func cardVeiw() -> some View {
        ZStack {
            let radius: CGFloat = 30
            VStack(spacing: 0) {
                LinearGradient(colors: [bColor, gColor], startPoint: .topLeading, endPoint: .trailing)
                    .frame(height: System.screen(.height, 0.65) + radius)
                    .overlay {
                        VStack(spacing: 0) {
                            cardTab(radius)
                            Spacer()
                        }
                        .foregroundColor(.white)
                        .monospacedDigit()
                    }
                    .cornerRadius(radius)
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                RoundedRectangle(cornerRadius: radius)
                    .foregroundColor(.primary)
                    .frame(height: System.screen(.height, 0.5))
                    .blendMode(.destinationOut)
                    .overlay {
                        detailList()
                    }
            }
            .ignoresSafeArea()
        }
        .compositingGroup()
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func cardTab(_ radius: CGFloat) -> some View {
        let cardHeight = System.screen(.height, 0.19) + radius
        let pLeading: CGFloat = 30
        let pTrailing: CGFloat = 20
        ScrollView(.vertical, showsIndicators: false) {
            ZStack {
                TabView(selection: $selected) {
                    ForEach(budget.book) { card in
                        VStack {
                            CardContent(inject: container, card: card)
                            Spacer()
                        }
                        .padding(.leading, pLeading)
                        .padding(.trailing, pTrailing)
                        .tag(card)
                    }
                    VStack {
                        Spacer()
                        Button(width: 50, height: 50, color: .green, radius: 50) {
                            
                        } content: {
                            Image(systemName: "plus")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .tag(Card.blank())
                }
                .tabViewStyle(.page(indexDisplayMode: .always))

                VStack {
                    HStack {
                        Spacer()
                        cardEditButton()
                    }
                    Spacer()
                }
                .padding(.leading, pLeading)
                .padding(.trailing, pTrailing)
            }
            .padding(.top, radius)
            .frame(height: cardHeight, alignment: .top)
        }
        .ignoresSafeArea(.keyboard)
        .scrollDisabled(true)
    }

    @ViewBuilder
    private func cardEditButton() -> some View {
        Menu {
            Button {
                container.interactor.system.PushActionView(.EditCard(budget, selected))
            } label: {
                Label("global.edit", systemImage: "pencil")
            }

            NavigationLink {
                BookOrderView(budget: budget)
            } label: {
                Label("view.header.book.order", systemImage: "arrow.up.arrow.down")
            }

//            Button {
//                container.interactor.system.PushRouterView(.BookOrder(budget))
//            } label: {
//                Label("view.header.book.order", systemImage: "arrow.up.arrow.down")
//            }

            Button(role: .destructive) {
                showDeleteAlert = true
            } label: {
                Label("global.delete", systemImage: "trash")
            }

            if selected.isForever {
                Button(role: .destructive) {
                    showArchiveAlert = true
                } label: {
                    Label("global.archive", systemImage: "archivebox")
                }
            }
        } label: {
            Image(systemName: "ellipsis")
                .rotationEffect(.degrees(90))
                .frame(width: 40, height: 40)
                .background(Color.transparent)
        }
        .font(.system(size: 28))
    }

    @ViewBuilder
    private func detailList() -> some View {
        ScrollViewReader { proxy in
            List {
                EmptyView().id("top")
                if current.pinnedArray.count != 0 {
                    detailSection(
                        "panel.record.create.pinned.label", current.pinnedArray, current.pinnedCost)
                }
                ForEach(current.dateDict.keys.elements.reversed(), id: \.self) { k in
                    let title = k.string("yyyy.MM.dd EE")
                    detailSection(title, current.dateDict[k]!.records, current.dateDict[k]!.cost)
                }
                Block(height: 100)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .font(.system(size: 20, weight: .regular))
            .monospacedDigit()
            .padding(.top)
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
                    .font(.system(size: 28, weight: .medium))
                    .foregroundLinearGradient([bColor, gColor])
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

    @ViewBuilder
    private func alertDeleteButton() -> some View {
        Button("global.delete", role: .destructive) {
            withAnimation(.quick) {
                container.interactor.data.DeleteCard(budget, selected)
            }
        }
    }

    @ViewBuilder
    private func alertArchiveButton() -> some View {
        Button("global.archive", role: .destructive) {
            withAnimation(.quick) {
                container.interactor.data.ArchiveCard(budget, selected)
            }
        }
    }
}

extension HomeViewV2 {
    fileprivate func handleOnAppeared() {
        bColor = selected.bgColor[0]
        gColor = selected.bgColor[1]
    }
}

#if DEBUG
struct HomeViewV2_Previews: PreviewProvider {
    static var previews: some View {
        HomeViewV2(budget: .preview, current: .preview, selected: .constant(.preview))
            .inject(DIContainer.preview)
            .environment(\.locale, .us)
            .preferredColorScheme(.light)
    }
}
#endif
