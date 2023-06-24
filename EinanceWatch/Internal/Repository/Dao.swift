import SwiftUI

struct Dao: DataDao, WatchDataDao {}

extension Dao: WatchRepository {}
