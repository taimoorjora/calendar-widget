import Foundation

struct CalendarGrid: Equatable {
    let monthName: String
    let weekdaySymbols: [String]
    let days: [Int?]

    static func make(
        year: Int,
        month: Int,
        calendar: Calendar = .autoupdatingCurrent,
        locale: Locale = .autoupdatingCurrent
    ) -> CalendarGrid {
        guard
            let firstDay = calendar.date(
                from: DateComponents(year: year, month: month, day: 1)
            ),
            let dayRange = calendar.range(of: .day, in: .month, for: firstDay)
        else {
            return CalendarGrid(
                monthName: "",
                weekdaySymbols: [],
                days: []
            )
        }

        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = locale
        formatter.setLocalizedDateFormatFromTemplate("MMMM")

        let firstWeekdayIndex = calendar.firstWeekday - 1
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let orderedSymbols = Array(
            symbols[firstWeekdayIndex...] + symbols[..<firstWeekdayIndex]
        )

        let weekday = calendar.component(.weekday, from: firstDay)
        let leadingBlanks = (weekday - calendar.firstWeekday + 7) % 7
        var days = Array<Int?>(repeating: nil, count: leadingBlanks)
        days.append(contentsOf: dayRange.map(Optional.some))
        days.append(
            contentsOf: Array<Int?>(
                repeating: nil,
                count: max(0, 42 - days.count)
            )
        )

        return CalendarGrid(
            monthName: formatter.string(from: firstDay),
            weekdaySymbols: orderedSymbols,
            days: Array(days.prefix(42))
        )
    }
}
