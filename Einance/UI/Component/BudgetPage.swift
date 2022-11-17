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
        VStack(spacing: 0) {
            Dashboard(budget: budget)
                .padding(.horizontal)
            
            TabView(selection: $current) {
                ForEach(budget.book) { card in
                    CardRect(card: card)
                        .padding()
                        .tag(card)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .frame(height: Device.screen.height*0.36)
            
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 15) {
                    ForEach(current.dateDict.keys.sorted(by: { $0 > $1 }), id: \.self) { date in
                        HStack {
                            Text(date.String("MM/dd EEEE", .init(identifier: Locale.preferredLanguages[0])))
                            Block(height: 1, color: .section)
                            Text("\(current.dateDict[date]!.cost.description) $")
                        }
                        .foregroundColor(.gray)
                        .font(.caption)
                        ForEach(current.dateDict[date]!.records) { record in
                            RecordRow(record: record, color: current.color)
                        }
                    }
                }
            }
            .monospacedDigit()
            .padding(.horizontal)
            AddRecordButton(current: $current)
            Spacer(minLength: 0)
        }
        .transition(.opacity)
        .animation(.quick, value: current)
    }
}

// MARK: - Function
extension BudgetPage {
}

struct BudgetPage_Previews: PreviewProvider {
    static var previews: some View {
        BudgetPage(budget: .preview, current: .preview)
    }
}
