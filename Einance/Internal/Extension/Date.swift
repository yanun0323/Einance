import SwiftUI

extension Date {
    static var zero: Date = .init(timeIntervalSince1970: 0)
    var key: Date {
        return Date(from: self.string(.Numeric), .Numeric) ?? .zero
    }
    
    var in24H : Int {
        return self.unix%86400
    }
}
