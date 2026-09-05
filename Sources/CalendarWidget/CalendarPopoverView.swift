import AppKit
import Combine
import SwiftUI

struct CalendarPopoverView: View {
    @AppStorage("showDateInMenuBar") private var showDateInMenuBar = false
    @State private var noteText = DailyNoteStore.note()
    @State private var today = Calendar.autoupdatingCurrent.startOfDay(for: .now)
    @State private var displayedYear = Calendar.autoupdatingCurrent.component(
        .year,
        from: .now
    )

    private let dateRefreshTimer = Timer.publish(
        every: 60,
        on: .main,
        in: .common
    ).autoconnect()

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 18),
        count: 4
    )

    var body: some View {
        VStack(spacing: 18) {
            header

            LazyVGrid(columns: columns, alignment: .leading, spacing: 22) {
                ForEach(1...12, id: \.self) { month in
                    MonthView(year: displayedYear, month: month, today: today)
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 6) {
                Text("Today's note")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                TextField("Write something for today", text: $noteText)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: noteText) { newValue in
                        DailyNoteStore.save(newValue)
                    }
            }

            HStack {
                Toggle("Show date in menu bar", isOn: $showDateInMenuBar)
                    .toggleStyle(.switch)

                Spacer()

                Button("Quit Calendar Widget") {
                    NSApplication.shared.terminate(nil)
                }
            }
            .controlSize(.small)
        }
        .padding(18)
        .frame(width: 720)
        .onReceive(dateRefreshTimer) { _ in
            refreshToday()
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .NSCalendarDayChanged)
        ) { _ in
            refreshToday()
        }
    }

    private var header: some View {
        HStack {
            Button {
                displayedYear -= 1
            } label: {
                Label("Previous year", systemImage: "chevron.left")
                    .labelStyle(.iconOnly)
            }
            .keyboardShortcut(.leftArrow, modifiers: .command)

            Spacer()

            Text(String(displayedYear))
                .font(.title3.weight(.semibold))

            Spacer()

            Button("Today") {
                let currentDate = Date.now
                refreshToday(at: currentDate)
                displayedYear = Calendar.autoupdatingCurrent.component(
                    .year,
                    from: currentDate
                )
            }

            Button {
                displayedYear += 1
            } label: {
                Label("Next year", systemImage: "chevron.right")
                    .labelStyle(.iconOnly)
            }
            .keyboardShortcut(.rightArrow, modifiers: .command)
        }
        .buttonStyle(.plain)
    }

    private func refreshToday(at date: Date = .now) {
        let calendar = Calendar.autoupdatingCurrent
        let newToday = calendar.startOfDay(for: date)

        guard newToday != today else { return }

        let followedCurrentYear = displayedYear == calendar.component(
            .year,
            from: today
        )

        today = newToday
        noteText = DailyNoteStore.note(for: newToday)

        if followedCurrentYear {
            displayedYear = calendar.component(.year, from: newToday)
        }
    }
}
