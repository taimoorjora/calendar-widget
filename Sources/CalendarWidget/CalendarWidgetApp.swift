import AppKit
import SwiftUI

@main
struct CalendarWidgetApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let preferenceKey = "showDateInMenuBar"
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var preferenceObserver: NSObjectProtocol?
    private var globalClickMonitor: Any?
    private var localClickMonitor: Any?
    private var dateTimer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        UserDefaults.standard.register(defaults: [preferenceKey: false])
        NSApp.setActivationPolicy(.accessory)

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.target = self
        statusItem.button?.action = #selector(togglePopover)
        statusItem.button?.sendAction(on: [.leftMouseUp])
        statusItem.button?.toolTip = "Calendar Widget"

        popover = NSPopover()
        popover.behavior = .transient
        popover.animates = true
        popover.contentSize = NSSize(width: 720, height: 650)
        popover.contentViewController = NSHostingController(
            rootView: CalendarPopoverView()
        )

        preferenceObserver = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.updateStatusItem()
            }
        }

        dateTimer = Timer.scheduledTimer(
            withTimeInterval: 60,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor in
                self?.updateStatusItem()
            }
        }

        installOutsideClickMonitors()
        updateStatusItem()
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let preferenceObserver {
            NotificationCenter.default.removeObserver(preferenceObserver)
        }
        if let globalClickMonitor {
            NSEvent.removeMonitor(globalClickMonitor)
        }
        if let localClickMonitor {
            NSEvent.removeMonitor(localClickMonitor)
        }
        dateTimer?.invalidate()
    }

    private func installOutsideClickMonitors() {
        let clickMask: NSEvent.EventTypeMask = [
            .leftMouseDown,
            .rightMouseDown,
            .otherMouseDown
        ]

        globalClickMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: clickMask
        ) { [weak self] _ in
            Task { @MainActor in
                self?.closePopoverIfClickIsOutside()
            }
        }

        localClickMonitor = NSEvent.addLocalMonitorForEvents(
            matching: clickMask
        ) { [weak self] event in
            Task { @MainActor in
                self?.closePopoverIfClickIsOutside()
            }
            return event
        }
    }

    private func closePopoverIfClickIsOutside() {
        guard
            popover.isShown,
            let popoverWindow = popover.contentViewController?.view.window
        else {
            return
        }

        let clickLocation = NSEvent.mouseLocation
        let clickedPopover = popoverWindow.frame.contains(clickLocation)
        let clickedStatusItem = statusItem.button?.window?.frame.contains(
            clickLocation
        ) == true

        if !clickedPopover && !clickedStatusItem {
            popover.performClose(nil)
        }
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(
                relativeTo: button.bounds,
                of: button,
                preferredEdge: .minY
            )
            popover.contentViewController?.view.window?.becomeKey()
        }
    }

    private func updateStatusItem() {
        guard let button = statusItem.button else { return }
        let note = DailyNoteStore.note()

        if UserDefaults.standard.bool(forKey: preferenceKey) {
            button.image = nil
            let day = String(
                Calendar.autoupdatingCurrent.component(.day, from: .now)
            )
            button.title = note.isEmpty ? day : [day, note].joined(separator: " · ")
        } else {
            button.title = ""
            button.image = NSImage(
                systemSymbolName: "calendar",
                accessibilityDescription: "Open Calendar Widget"
            )
        }

        button.toolTip = note.isEmpty ? "Calendar Widget" : note
    }
}
