import SwiftUI
import Ditto

protocol WatchDataDao {}

extension WatchDataDao where Self: WatchDataRepository {
    func upsertBudgetData(_ data: Data) throws {
        UserDefaults.currentBudgetData = data
    }
    
    func getBudgetData() throws -> Data? {
        return UserDefaults.currentBudgetData
    }
}

fileprivate extension UserDefaults {
    @UserDefault(key: "currentBudgetData")
    static var currentBudgetData: Data?
}
