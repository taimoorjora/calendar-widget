import Foundation

enum DailyNoteStore {
    private static let defaultsKey = "dailyNotes"
    private static let calendar = Calendar.autoupdatingCurrent

    static func note(for date: Date = .now) -> String {
        let notes = UserDefaults.standard.dictionary(forKey: defaultsKey)
            as? [String: String] ?? [:]
        return notes[key(for: date)] ?? ""
    }

    static func save(_ note: String, for date: Date = .now) {
        var notes = UserDefaults.standard.dictionary(forKey: defaultsKey)
            as? [String: String] ?? [:]
        let dateKey = key(for: date)
        let cleanedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)

        if cleanedNote.isEmpty {
            notes.removeValue(forKey: dateKey)
        } else {
            notes[dateKey] = cleanedNote
        }

        UserDefaults.standard.set(notes, forKey: defaultsKey)
    }

    private static func key(for date: Date) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return [components.year ?? 0, components.month ?? 0, components.day ?? 0]
            .map(String.init)
            .joined(separator: "-")
    }
}
