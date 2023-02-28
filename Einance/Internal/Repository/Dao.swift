import SwiftUI

struct Dao: DataDao, UserSettingDao {}

extension Dao: Repository {}
