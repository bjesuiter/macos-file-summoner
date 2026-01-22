import Foundation

enum FileServiceError: LocalizedError {
    case invalidFilename(String)
    case fileExists(String)
    case creationFailed(String)
    case permissionDenied(String)

    var errorDescription: String? {
        switch self {
        case .invalidFilename:
            return NSLocalizedString("error_invalid_filename", comment: "")
        case .fileExists:
            return NSLocalizedString("error_file_exists", comment: "")
        case .creationFailed:
            return NSLocalizedString("error_create_failed", comment: "")
        case .permissionDenied:
            return NSLocalizedString("error_permission_denied", comment: "")
        }
    }
}

enum FileService {
    static func validateFilename(_ input: String) -> String? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let forbidden: [Character] = ["/", "\\", "\0", ":"]
        guard !trimmed.contains(where: { forbidden.contains($0) }) else { return nil }
        guard !trimmed.contains("..") else { return nil }

        let filename = (trimmed as NSString).lastPathComponent
        guard !filename.isEmpty else { return nil }

        return filename
    }

    static func createFile(at directory: String, named filename: String) -> Result<URL, FileServiceError> {
        let fileManager = FileManager.default
        let fullPath = (directory as NSString).appendingPathComponent(filename)
        let fileURL = URL(fileURLWithPath: fullPath)

        if fileManager.fileExists(atPath: fullPath) {
            return .failure(.fileExists(fullPath))
        }

        guard fileManager.isWritableFile(atPath: directory) else {
            return .failure(.permissionDenied(directory))
        }

        let success = fileManager.createFile(atPath: fullPath, contents: nil, attributes: nil)

        if success {
            return .success(fileURL)
        }

        return .failure(.creationFailed(fullPath))
    }
}
