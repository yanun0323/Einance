//
//  BudgetSlice.swift
//  Einance
//
//  Created by YanunYang on 2022/11/11.
//

import SwiftUI
import UIComponent

struct BudgetSlice: View {
    @State var budget: Budget
    @State var current: Card
    
    var body: some View {
        VStack {
            TabView(selection: $current) {
                ForEach(budget.book) { card in
                    CardRectangle(card: card)
                        .padding()
                        .tag(card)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .background(Color.section.gradient)
            .frame(maxHeight: Device.screen.height*0.36)
            .padding(.vertical)
            
            ForEach(current.records) { record in
                Text(record.cost.description)
                    .background()
            }
            Spacer()
        }
    }
}

// MARK: - Function
extension BudgetSlice {
}

struct BudgetSlice_Previews: PreviewProvider {
    static var previews: some View {
        BudgetSlice(budget: .preview, current: .preview)
            .background(Color.gray)
    }
}
