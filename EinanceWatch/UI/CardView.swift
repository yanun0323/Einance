import SwiftUI
import Ditto

struct CardView: View {
    @Environment(\.injected) private var container
    @Environment(\.presentationMode) private var presentation
    @StateObject private var record: Record = .blank()
    @State private var costInput: String = "0"
    @State private var memoInput: String = ""
    @ObservedObject var card: Card
    var body: some View {
        NavigationStack {
            VStack {
                addRecordButton()
                    .padding(.vertical)
                detailList()
            }
            .navigationTitle(card.name)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder
    private func addRecordButton() -> some View {
        NavigationLink {
            addRecordPannel()
        } label: {
            LinearGradient(colors: [.green], startPoint: .topLeading, endPoint: .trailing)
                .frame(height: 40)
                .cornerRadius(7)
                .overlay {
                    Text("+")
                        .font(.title2)
                }
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private func addRecordPannel() -> some View {
        ScrollView(.vertical, showsIndicators: true) {
            LazyVStack {
                addRecordPannelLabel("panel.record.create.cost.label")
                DigitTextField(text: $costInput)
                addRecordPannelLabel("panel.record.create.memo.label")
                ZStack {
                    HStack {
                        Spacer()
                        Text("panel.record.create.memo.placeholder")
                            .foregroundColor(.section)
                            .padding(.trailing, 5)
                    }
                    TextField("", text: $memoInput)
                        .multilineTextAlignment(.trailing)
                }
                
                Button(width: System.screen.width, height: 40, colors: card.bgColor, radius: 9) {
                    presentation.wrappedValue.dismiss()
                } content: {
                    Text("button.record.create")
                        .foregroundColor(.white)
                }
                .padding(.top)
            }
            .navigationTitle("button.record.create")
        }
    }
    
    @ViewBuilder
    private func addRecordPannelLabel(_ key: LocalizedStringKey) -> some View {
        HStack {
            Text(key)
                .foregroundColor(.gray)
                .font(.caption)
            Spacer()
        }
    }
    
    @ViewBuilder
    private func detailList() -> some View {
        ScrollViewReader { proxy in
            List {
                EmptyView().id("top")
                if card.pinnedArray.count != 0 {
                    detailSection(
                        "panel.record.create.pinned.label", card.pinnedArray, card.pinnedCost)
                }
                ForEach(card.dateDict.keys.elements.reversed(), id: \.self) { k in
                    let title = k.string("yy.MM.dd EE")
                    detailSection(title, card.dateDict[k]!.records, card.dateDict[k]!.cost)
                }
            }
            .listStyle(.plain)
            .font(.system(size: 20, weight: .regular))
            .monospacedDigit()
            .padding(.top)
        }
        .scrollIndicators(.hidden)
    }
    
    @ViewBuilder
    private func detailSection(_ title: String, _ records: [Record], _ sum: Decimal) -> some View {
        let fontSize: CGFloat = 14
        Section {
            ForEach(records) { r in
                HStack {
                    Text(r.memo)
                        .kerning(1)
                        .font(.system(size: fontSize))
                        .lineLimit(1)
                    Spacer()
                    Text("\(r.cost.description) $")
                        .font(.system(size: fontSize))
                        .monospacedDigit()
                        .lineLimit(1)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        withAnimation(.quick) {
//                            container.interactor.data.DeleteRecord(budget, selected, r)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    
                    Button(role: .none) {
//                        container.interactor.system.PushActionView(.EditRecord(budget, selected, r))
                    } label: {
                        Label("Edit", systemImage: "square.and.pencil")
                    }
                }
                .swipeActions(edge: .leading, allowsFullSwipe: false) {
//                    if selected.pinned {
//                        Button(role: .cancel) {
//                            withAnimation(.quick) {
//                                let pinned = !r.pinned
//                                container.interactor.data.UpdateRecord(
//                                    budget, selected, r, date: r.date, cost: r.cost, memo: r.memo,
//                                    pinned: pinned)
//                            }
//                        } label: {
//                            Label("Fixed", systemImage: "pin")
//                        }
//                    }
                }
                .opacity(0.3)
                .fontWeight(.regular)
                .padding(.leading)
            }
        } header: {
            HStack {
                Text(LocalizedStringKey(title))
                    .font(.system(size: fontSize, weight: .medium))
                    .foregroundLinearGradient(card.bgColor)
                    .monospacedDigit()
                    .lineLimit(1)
                Spacer()
                Text("\(sum.description) $")
                    .font(.system(size: fontSize, weight: .regular))
                    .opacity(0.7)
                    .lineLimit(1)
                
            }
            .background()
        }
        .listRowBackground(Color.clear)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(card: .preview)
            .inject(.preview)
    }
}
