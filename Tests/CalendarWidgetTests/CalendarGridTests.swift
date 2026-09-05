import Foundation
import Testing
@testable import CalendarWidget

struct CalendarGridTests {
    @Test
    func leapYearFebruaryUsesSundayFirstGrid() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 1
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let grid = CalendarGrid.make(
            year: 2024,
            month: 2,
            calendar: calendar,
            locale: Locale(identifier: "en_US")
        )

        #expect(grid.monthName == "February")
        #expect(grid.weekdaySymbols == ["S", "M", "T", "W", "T", "F", "S"])
        #expect(grid.days.count == 42)
        #expect(grid.days.prefix(4).allSatisfy { $0 == nil })
        #expect(grid.days[4] == 1)
        #expect(grid.days.compactMap(\.self).last == 29)
    }

    @Test
    func mondayFirstGridRotatesSymbolsAndDates() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let grid = CalendarGrid.make(
            year: 2024,
            month: 1,
            calendar: calendar,
            locale: Locale(identifier: "en_GB")
        )

        #expect(grid.weekdaySymbols == ["M", "T", "W", "T", "F", "S", "S"])
        #expect(grid.days[0] == 1)
        #expect(grid.days.compactMap(\.self).last == 31)
    }
}
