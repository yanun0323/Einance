//
//  BudgetPage.swift
//  Einance
//
//  Created by YanunYang on 2022/11/11.
//

import SwiftUI
import UIComponent

struct BudgetPage: View {
    @State var budget: Budget
    @State var current: Card
    
    var body: some View {
        VStack {
            TabView(selection: $current) {
                ForEach(budget.book) { card in
                    CardRect(card: card)
                        .padding()
                        .tag(card)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .frame(maxHeight: Device.screen.height*0.36)
            .padding(.vertical)
            
            VStack {
                ForEach(current.records) { record in
                    if current.dateDict[record.date]?.uuid == record.uuid {
                        Text(record.date.String(.Date))
                    }
                    HStack {
                        Text(record.date.String(.Date))
                        Spacer()
                        Text(record.memo)
                        Spacer()
                        Text(record.cost.description)
                    }
                    .background()
                }
            }
            .monospacedDigit()
            .padding(.horizontal)
            Spacer()
        }
    }
}

// MARK: - Function
extension BudgetPage {
}

struct BudgetSlice_Previews: PreviewProvider {
    static var previews: some View {
        BudgetPage(budget: .preview, current: .preview)
            .background(Color.gray)
    }
}
