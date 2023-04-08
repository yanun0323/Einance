import SwiftUI

extension Interactor {
    func CalculateNextDate(_ start: Date, days: Int) -> Date { Self.CalculateNextDate(start, days: days) }
}

extension Interactor {
    static func CalculateNextDate(_ start: Date, days: Int) -> Date {
        let nextMonthDay1 = start.AddMonth(1).firstDayOfMonth
        
        if days >= nextMonthDay1.daysOfMonth {
            let lastDayOfNextMonth = nextMonthDay1.AddMonth(1).AddDay(-1)
            return lastDayOfNextMonth
        }
        return nextMonthDay1.AddDay(days-1)
    }
}
