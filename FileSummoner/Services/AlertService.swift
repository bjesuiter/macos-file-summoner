import AppKit

enum AlertService {
    static func showFilenameDialog(defaultName: String = "newFile.txt") -> String? {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("create_new_file", comment: "")
        alert.informativeText = NSLocalizedString("filename_prompt", comment: "")
        alert.alertStyle = .informational

        let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
        textField.stringValue = defaultName
        textField.selectText(nil)
        alert.accessoryView = textField

        alert.addButton(withTitle: NSLocalizedString("button_create", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("button_cancel", comment: ""))
        alert.window.makeFirstResponder(textField)

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            return textField.stringValue
        }

        return nil
    }

    static func showError(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .critical
        alert.addButton(withTitle: NSLocalizedString("button_ok", comment: ""))
        alert.runModal()
    }
}
