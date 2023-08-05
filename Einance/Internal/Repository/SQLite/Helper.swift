import SwiftUI
import SQLite
import Sworm

extension Card.Display: Value {
    public typealias Datatype = Int64
    
    public static var declaredDatatype: String {
        return Int64.declaredDatatype
    }
    
    public static func fromDatatypeValue(_ datatypeValue: Int64) -> Card.Display {
        return Card.Display(rawValue: Int(datatypeValue)) ?? .forever
    }
    
    public var datatypeValue: Int64 {
        Int64(self.rawValue)
    }
}

extension TagType: Value {
    public typealias Datatype = Int64
    
    public static var declaredDatatype: String {
        return Int64.declaredDatatype
    }
    
    public static func fromDatatypeValue(_ datatypeValue: Int64) -> TagType {
        return TagType(rawValue: Int(datatypeValue)) ?? .unknown
    }
    
    public var datatypeValue: Int64 {
        Int64(self.rawValue)
    }
}
