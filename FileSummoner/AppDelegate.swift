import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.activate(ignoringOtherApps: true)

        guard let finderPath = FinderService.getActiveWindowPath() else {
            AlertService.showError(
                title: NSLocalizedString("error_title", comment: ""),
                message: NSLocalizedString("error_finder_path", comment: "")
            )
            NSApplication.shared.terminate(self)
            return
        }

        showSwiftUIDialog(directoryPath: finderPath)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    private func showSwiftUIDialog(directoryPath: String) {
        let contentView = FileCreationView(
            directoryPath: directoryPath,
            onCancel: { [weak self] in
                NSApplication.shared.terminate(self)
            },
            onSuccess: { [weak self] _ in
                NSApplication.shared.terminate(self)
            }
        )

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 220),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )

        window.title = NSLocalizedString("app_title", comment: "")
        window.center()
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        window.level = .floating

        self.window = window
    }
}
