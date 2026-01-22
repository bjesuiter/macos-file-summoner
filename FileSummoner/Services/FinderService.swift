import Foundation

enum FinderService {
    static func getActiveWindowPath() -> String? {
        let script = """
        tell application "Finder"
            if (count of Finder windows) is 0 then
                set dir to (desktop as alias)
            else
                set dir to ((target of Finder window 1) as alias)
            end if
            return POSIX path of dir
        end tell
        """

        return executeAppleScript(script)
    }

    private static func executeAppleScript(_ source: String) -> String? {
        var error: NSDictionary?

        guard let appleScript = NSAppleScript(source: source) else {
            print("[FinderService] Failed to create AppleScript")
            return nil
        }

        let result = appleScript.executeAndReturnError(&error)

        if let error = error {
            print("[FinderService] AppleScript error: \(error)")
            return nil
        }

        return result.stringValue
    }
}
