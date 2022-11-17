//
//  CardRect.swift
//  Einance
//
//  Created by YanunYang on 2022/11/11.
//

import SwiftUI
import UIComponent

struct CardRect: View {
    let card: Card
    var body: some View {
        GeometryReader { p in
            VStack(alignment: .trailing, spacing: size(p)*0.07) {
                HStack(alignment: .top, spacing: 0) {
                    Text(card.tag)
                        .font(.system(size: size(p)*0.05, weight: .light, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                    Text(card.name)
                        .font(.system(size: size(p)*0.11, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                }
                .frame(height: size(p)*0.11)
                VStack(alignment: .trailing, spacing: -size(p)*0.02) {
                    Text(card.cost.description)
                        .font(.system(size: size(p)*0.13, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    Text(card.amount.description)
                        .font(.system(size: size(p)*0.13, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(0.3)
                }
            }
            .monospacedDigit()
            .padding(.horizontal, size(p)*0.06)
            .frame(width: size(p), height: size(p)*0.66)
            .background(card.color)
            .cornerRadius(15)
            .contextMenu {
                Button {
                    
                } label: {
                    Label("edit", systemImage: "square.and.pencil")
                }
                
                Button(role: .destructive) {
                    
                } label: {
                    Label("delete", systemImage: "trash")
                }
            }
        }
    }
}

// MARK: - Function
extension CardRect {
    func size(_ proxy: GeometryProxy) -> CGFloat {
        return proxy.size.width
    }
}

struct CardRect_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CardRect(card: .preview)
                .frame(width: Device.screen.width, height: Device.screen.width*0.66)
                .padding()
            CardRect(card: .preview)
                .frame(width: Device.screen.width*1.3, height: Device.screen.width*0.66*1.3)
                .padding()
            CardRect(card: .preview2)
                .frame(width: Device.screen.width, height: Device.screen.width*0.66)
                .padding()
        }
        .previewLayout(.sizeThatFits)
    }
}
