//
//  AddRecordButton.swift
//  Einance
//
//  Created by YanunYang on 2022/11/14.
//

import SwiftUI
import UIComponent

struct AddRecordButton: View {
    @Binding var current: Card
    
    var size: CGFloat {
        Device.screen.width*0.2
    }
    
    var body: some View {
        ButtonCustom(width: size, height: size, color: .section.opacity(0.7),
                     radius: size/2, shadow: 1.2) {
            
        } content: {
            Image(systemName: "plus")
                .font(.system(size: size*0.66, weight: .thin))
                .foregroundColor(current.color)
        }
    }
}

struct AddRecordButton_Previews: PreviewProvider {
    static var previews: some View {
        AddRecordButton(current: .constant(.preview))
    }
}
