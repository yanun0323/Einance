import SwiftUI
import Ditto

struct ConceptView: View {
    @State private var selected = 0
    
    private let cardRatio = CGFloat(0.93)
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
            ForEach(0 ... 5, id: \.self) { i in
                cardView(i)
                    .background {
                        if i < 5 {
                            cardView(i+1, .red)
                                .offset(x: CGSize.collection.width * (i == selected ? cardRatio + cardSpacing : 1))
                                .layoutPriority(1)
                        }

                        if i > 0 {
                            cardView(i-1, .red)
                                .offset(x: -CGSize.collection.width * (i == selected ? cardRatio + cardSpacing : 1))
                                .layoutPriority(1)
                        }
                    }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeOut(duration: 0.2), value: selected)
        .scaledToFill()
    }
    
    @ViewBuilder
    private func cardView(_ tag: Int, _ color: Color = .red) -> some View {
        Text(tag.description)
            .frame(size: .collection.x(cardRatio))
            .background(color)
            .cornerRadius(CGSize.collection.x(0.1).height)
            .contextMenu {
                Label("Delete", systemImage: "trash.fill")
            }
            .frame(size: .collection)
    }
    
    @ViewBuilder
    private func listView() -> some View {
        VStack(spacing: 0) {
            
        }
    }
}

struct ConceptView_Previews: PreviewProvider {
    static var previews: some View {
        ConceptView()
    }
}
