//
//  HomeHeader.swift
//  Einance
//
//  Created by Yanun on 2022/11/19.
//

import SwiftUI
import UIComponent

struct HomeHeader: View {
    var body: some View {
        HStack {
            ButtonCustom(width: 40, height: 40) {
                
            } content: {
                Image(systemName: "gearshape")
                    .font(.title2)
            }
            Spacer()
            ButtonCustom(width: 40, height: 40) {
                
            } content: {
                Image(systemName: "rectangle.on.rectangle.angled")
                    .font(.title2)
            }

            ButtonCustom(width: 40, height: 40) {
                
            } content: {
                Image(systemName: "rectangle.fill.badge.plus")
                    .font(.title2)
            }
        }
        .foregroundColor(.gray)
    }
}

struct HomeHeader_Previews: PreviewProvider {
    static var previews: some View {
        HomeHeader()
    }
}
