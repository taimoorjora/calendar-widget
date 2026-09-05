import SwiftUI

struct MonthView: View {
    let year: Int
    let month: Int
    let today: Date

    private let calendar = Calendar.autoupdatingCurrent

    var body: some View {
        let grid = CalendarGrid.make(
            year: year,
            month: month,
            calendar: calendar
        )

        VStack(alignment: .leading, spacing: 8) {
            Text(grid.monthName)
                .font(.headline)

            Grid(horizontalSpacing: 3, verticalSpacing: 3) {
                GridRow {
                    ForEach(
                        Array(grid.weekdaySymbols.enumerated()),
                        id: \.offset
                    ) { _, symbol in
                        Text(symbol)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }

                ForEach(0..<6, id: \.self) { week in
                    GridRow {
                        ForEach(0..<7, id: \.self) { weekday in
                            dayCell(grid.days[(week * 7) + weekday])
                        }
                    }
                }
            }
            .font(.caption.monospacedDigit())
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(grid.monthName) \(year)")
    }

    @ViewBuilder
    private func dayCell(_ day: Int?) -> some View {
        if let day {
            Text(day.formatted())
                .frame(maxWidth: .infinity, minHeight: 18)
                .background {
                    if isToday(day) {
                        Circle()
                            .fill(.tint)
                    }
                }
                .foregroundStyle(dayTextColor(for: day))
                .accessibilityLabel(
                    isToday(day) ? "\(day), today" : day.formatted()
                )
        } else {
            Color.clear
                .frame(maxWidth: .infinity, minHeight: 18)
                .accessibilityHidden(true)
        }
    }

    private func isToday(_ day: Int) -> Bool {
        guard
            let date = calendar.date(
                from: DateComponents(year: year, month: month, day: day)
            )
        else {
            return false
        }

        return calendar.isDate(date, inSameDayAs: today)
    }

    private func dayTextColor(for day: Int) -> Color {
        if isToday(day) {
            return .white
        }

        guard
            let date = calendar.date(
                from: DateComponents(year: year, month: month, day: day)
            )
        else {
            return .primary
        }

        return calendar.isDateInWeekend(date) ? .secondary : .primary
    }
}
