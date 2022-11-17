//
//  RecordRow.swift
//  Einance
//
//  Created by YanunYang on 2022/11/14.
//

import SwiftUI
import UIComponent

struct RecordRow: View {
    @State var record: Record
    @State var color: Color
    
    var body: some View {
        HStack {
            Block(width: 4, color: color)
                .padding(.trailing, 10)
            Text(record.memo)
                .foregroundColor(.primary50)
            Spacer()
            Text("\(record.cost.description) $")
        }
        .font(.system(size: 17, weight: .light, design: .rounded))
        .kerning(1)
        .padding(.vertical, 5)
        .padding(.horizontal)
        .monospacedDigit()
    }
}

struct RecordRow_Previews: PreviewProvider {
    static var previews: some View {
        RecordRow(record: .preview, color: .green)
            .previewLayout(.sizeThatFits)
    }
}
