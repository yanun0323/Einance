//
//  ContentView.swift
//  Einance
//
//  Created by YanunYang on 2022/11/10.
//

import SwiftUI
import UIComponent

struct ContentView: View {
    @EnvironmentObject var container: DIContainer
    @State var budget: Budget
    @State var current: Card
    
    init(injector: DIContainer) {
        self.budget = injector.interactor.data.CurrentBudget()
        self.current = injector.interactor.data.CurrentCard()
    }
    
    var body: some View {
        VStack {
            BudgetPage(budget: budget, current: current)
        }
        .background(Color.section.gradient)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(injector: .preview)
            .inject(DIContainer.preview)
    }
}
