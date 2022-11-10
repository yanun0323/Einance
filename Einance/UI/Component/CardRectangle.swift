//
//  CardRectangle.swift
//  Einance
//
//  Created by YanunYang on 2022/11/11.
//

import SwiftUI
import UIComponent

struct CardRectangle: View {
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
            .padding(.horizontal, size(p)*0.09)
            .frame(width: size(p), height: size(p)*0.66)
            .background(card.color)
            .cornerRadius(15)
        }
    }
}

// MARK: - Function
extension CardRectangle {
    func size(_ proxy: GeometryProxy) -> CGFloat {
        return proxy.size.width
    }
}

struct CardSpan_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CardRectangle(card: .preview)
                .frame(width: Device.screen.width, height: Device.screen.width*0.66)
                .padding()
            CardRectangle(card: .preview)
                .frame(width: Device.screen.width*1.3, height: Device.screen.width*0.66*1.3)
                .padding()
            CardRectangle(card: .preview2)
                .frame(width: Device.screen.width, height: Device.screen.width*0.66)
                .padding()
        }
        .previewLayout(.sizeThatFits)
    }
}
