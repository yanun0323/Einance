import SwiftUI

extension String {
    var localizedKey: LocalizedStringKey {
        return .init(self)
    }
    
    var localized: String {
        return String(localized: LocalizedStringResource(stringLiteral: self))
    }
}
