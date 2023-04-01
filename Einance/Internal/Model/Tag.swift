import SwiftUI

enum TagType: Int {
    case unknown, text, number
}

struct Tag {
    var id: Int64
    var chainID: UUID
    var type: TagType
    var value: String
    var count: Int
    var UpdatedAti: Int
    
    init(
        id: Int64 = 0,
        chainID: UUID = UUID(),
        type: TagType,
        value: String,
        count: Int = 0,
        updatedAti: Int = Date.now.in24H
    ) {
        self.id = id
        self.chainID = chainID
        self.type = type
        self.value = value
        self.count = count
        self.UpdatedAti = updatedAti
    }
}

extension Tag: Hashable {}
