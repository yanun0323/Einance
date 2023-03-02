import SwiftUI
import SQLite
import UIComponent

extension Decimal: Value {
    public typealias Datatype = String
    
    public static var declaredDatatype: String {
        return String.declaredDatatype
    }
    
    public static func fromDatatypeValue(_ datatypeValue: String) -> Decimal {
        if let d = Decimal(string: datatypeValue) {
            return d
        }
        print("[ERROR] transform string '\(datatypeValue)' to decimal failed")
        return 0
    }
    
    public var datatypeValue: String {
        return self.description
    }
}

extension Color: Value {
    public typealias Datatype = String
    
    public static var declaredDatatype: String {
        return String.declaredDatatype
    }
    
    public static func fromDatatypeValue(_ datatypeValue: String) -> Color {
        return Color(hex: datatypeValue)
    }
    
    public var datatypeValue: String {
        self.hex
    }
}

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
