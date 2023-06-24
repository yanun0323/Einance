import SwiftUI

protocol WatchRepository: DataRepository, WatchDataRepository {}

protocol WatchDataRepository {
    func upsertBudgetData(_:Data) throws
    func getBudgetData() throws -> Data?
}
