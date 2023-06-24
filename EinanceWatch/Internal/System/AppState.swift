import SwiftUI
import Combine
import Ditto

struct AppState {
    private static var `default`: AppState? = nil
    
    var currentBudget = PassthroughSubject<Budget, Never>()
    var message = PassthroughSubject<String, Never>()
}

extension AppState {
    static func get() -> Self {
        if Self.default.isNil {
            Self.default = Self()
        }
        return Self.default!
    }
}
