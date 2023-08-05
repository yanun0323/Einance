import SwiftUI
import Ditto

struct CardView: View {
    @Environment(\.injected) private var container
    @ObservedObject var budget: Budget
    @ObservedObject var card: Card
    
    @State private var showDeleteAlert = false
    @State private var showArchiveAlert = false
    
    private let cardPadding = CGFloat(30)
    
    var body: some View {
        LinearGradient(colors: card.bgColor, startPoint: .topLeading, endPoint: .trailing)
            .frame(size: .card)
            .cornerRadius(.cardRadius)
            .overlay {
                textContent()
            }
            .contextMenu(menuItems: contextMenuContent)
            .frame(size: .collection)
            .debug(.green)
            .confirmationDialog("card.context.alert.delete.title", isPresented: $showDeleteAlert, actions: {
                alertDeleteButton()
            }, message: {
                Text("card.context.alert.delete.title")
            })
            .confirmationDialog("card.context.alert.archive.title", isPresented: $showArchiveAlert, actions: {
                alertArchiveButton()
            }, message: {
                Text("card.context.alert.archive.title")
            })
    }
    
    @ViewBuilder
    private func textContent() -> some View {
        VStack(alignment: .trailing, spacing: 0) {
            HStack(spacing: 0) {
                if card.isForever {
                    Image(systemName: "pin.fill")
                        .rotationEffect(Angle(degrees: 40))
                        .padding(.trailing, 10)
                }
                Text(card.name)
                    .font(.system(size: 36, weight: .medium))
                Spacer()
            }
            VStack(alignment: .trailing, spacing: 0) {
                Text(card.cost.description)
                Text(card.balance.description)
                    .opacity(0.5)
            }
            .font(.system(size: 40, weight: .medium))
        }
        .foregroundColor(card.fColor)
        .monospacedDigit()
        .padding(cardPadding)
        .lineLimit(1)
    }
    
    @ViewBuilder
    private func contextMenuContent() -> some View {
        VStack(spacing: 0) {
            Button {
                container.interactor.system.PushActionView(.EditCard(budget, card))
            } label: {
                Label("global.edit", systemImage: "trash")
            }
            Button(role: .destructive) {
                showDeleteAlert = true
            } label: {
                Label("global.delete", systemImage: "trash.fill")
            }
            if card.isForever {
                Button {
                    showArchiveAlert = true
                } label: {
                    Label("global.archive", systemImage: "archivebox.fill")
                }
            }
        }
    }
    
    @ViewBuilder
    private func alertDeleteButton() -> some View {
        Button("global.delete", role: .destructive) {
            withAnimation(.quick) {
                container.interactor.data.DeleteCard(budget, card)
            }
        }
    }
    
    @ViewBuilder
    private func alertArchiveButton() -> some View {
        Button("global.archive", role: .destructive) {
            withAnimation(.quick) {
                container.interactor.data.ArchiveCard(budget, card)
            }
        }
    }
    
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(budget: .preview, card: .preview2)
            .inject(.preview)
    }
}
