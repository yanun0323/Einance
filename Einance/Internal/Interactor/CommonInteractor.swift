import SwiftUI
import Ditto

struct CommonInteractor {}

extension CommonInteractor {
    func CalculateNextDate(_ start: Date, days: Int) -> Date {
        let nextMonthDay1 = start.addMonth(1).firstDayOfMonth
        
        if days >= nextMonthDay1.daysOfMonth {
            let lastDayOfNextMonth = nextMonthDay1.addMonth(1).addDay(-1)
            return lastDayOfNextMonth
        }
        return nextMonthDay1.addDay(days-1)
    }
}
