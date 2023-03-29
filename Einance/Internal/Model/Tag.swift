import SwiftUI

enum TagType: Int {
    case unknown, text, number
}

struct Tag {
    var id: Int64
    var type: TagType
    var value: String
    var ts: Int64
    
    init(
        id: Int64 = 0,
        type: TagType,
        value: String,
        ts: Int64 = Int64(Date.now.unix%86400)
    ) {
        self.id = id
        self.type = type
        self.value = value
        self.ts = ts
    }
}
