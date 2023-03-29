import SwiftUI
import UIComponent
import UniformTypeIdentifiers

struct BookOrderView: View {
    @EnvironmentObject private var container: DIContainer
    
    @GestureState private var dragOffset: CGSize = .zero
    @State private var draggingOffset: CGSize = .zero
    @State private var draggingID: Int64?
    @State private var draggingFromIndex: Int?
    @State private var draggingOffsetFixed: Int = 0
    @State private var draggingUpdating: Bool = false
    
    @ObservedObject var budget: Budget
    
    @State private var info = "\n"
    private let defaultCardOffset: CGFloat = System.device.screen.width * 0.25
    
    // MARK: TODO: Check Refresh
    var body: some View {
        VStack(spacing: 30) {
            ViewHeader(title: "view.header.book.order")
            GeometryReader { proxy in
                listBlock(getCardOffset(proxy))
                    .padding()
            }
        }
        .modifyRouterBackground()
        .transition(.scale(scale: 0.95, anchor: .topTrailing).combined(with: .opacity))
    }
    
    @ViewBuilder
    private func listBlock(_ cardOffset: CGFloat) -> some View {
        ZStack {
            ForEach(budget.book) { card in
                CardRect(budget: budget, card: card, isOrder: true)
                    .shadow(radius: 5)
                    .offset(
                        x: draggingID == card.id ? draggingOffset.width : 0,
                        y: (draggingID == card.id ? CGFloat(draggingOffset.height) : 0 ) + CGFloat(card.index) * cardOffset)
                    .zIndex(Double(card.index))
                    .gesture(
                        DragGesture()
                            .onChanged({ value in
                                withAnimation(.shoot) {
                                    if draggingUpdating { return }
                                    draggingUpdating = true
                                    defer { draggingUpdating = false}
                                    var t = value.translation
                                    t.height += CGFloat(draggingOffsetFixed) * cardOffset
                                    draggingOffset = t
                                    draggingID = card.id
                                    let offset = Int(t.height)/Int(cardOffset)
                                    if offset != 1 && offset != -1 { return }
                                    let fromIndex = draggingFromIndex ?? card.index
                                    let toIndex = fromIndex + offset
                                    if toIndex < 0 || toIndex >= budget.book.count { return }
                
                                    budget.book[fromIndex].index = toIndex
                                    budget.book[toIndex].index = fromIndex
                                    draggingFromIndex = toIndex
                                    let from = budget.book[fromIndex]
                                    budget.book[fromIndex] = budget.book[toIndex]
                                    budget.book[toIndex] = from
                                    
                                    draggingOffsetFixed -= offset
                                    t.height += CGFloat(draggingOffsetFixed) * cardOffset
                                    draggingOffset = t
                                }
                            })
                            .onEnded({ value in
                                container.interactor.data.UpdateCardsOrder(budget)
                                draggingID = nil
                                draggingUpdating = false
                                draggingFromIndex = nil
                                draggingOffsetFixed = 0
                            })
                    )
            }
        }
    }
}

// MARK: - Function
extension BookOrderView {
    func getCardOffset(_ proxy: GeometryProxy) -> CGFloat {
        let offset = (proxy.size.height - proxy.size.width*0.66)/CGFloat(budget.book.count)
        return offset > defaultCardOffset ? defaultCardOffset : offset
    }
    
    func move(from source: IndexSet, to destination: Int) {
        let from = source.first ?? 0
        if from == destination { return }
        let fromCard = budget.book[from]
        for card in budget.book  {
            if card.index >= destination {
                card.index += 1
            }
        }
        fromCard.index = destination
        for i in 0 ..< budget.book.count {
            budget.book[i].index = i
        }
    }
}

#if DEBUG
struct BookOrderView_Previews: PreviewProvider {
    static var previews: some View {
        BookOrderView(budget: Budget.preview)
            .inject(DIContainer.preview)
    }
}
#endif

struct DragRelocateDelegate: DropDelegate {
    let item: Card
    @Binding var listData: [Card]
    @Binding var current: Card?
    @State private var drugItemLocation: CGPoint?
    @State private var hasChangedLocation: Bool = false
    
    func dropEntered(info: DropInfo) {
        if current == nil {
            current = item
            drugItemLocation = info.location
        }

        guard item != current,
              let current = current,
              let from = listData.firstIndex(of: current),
              let toIndex = listData.firstIndex(of: item) else { return }

              hasChangedLocation = true
              drugItemLocation = info.location

        if listData[toIndex] != current {
            listData.move(fromOffsets: IndexSet(integer: from), toOffset: toIndex > from ? toIndex + 1 : toIndex)
        }
    }

    func dropExited(info: DropInfo) {
        drugItemLocation = nil
    }

    func performDrop(info: DropInfo) -> Bool {
       hasChangedLocation = false
       drugItemLocation = nil
       current = nil
       return true
    }
    
}
