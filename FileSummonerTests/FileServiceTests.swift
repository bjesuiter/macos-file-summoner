import XCTest
@testable import FileSummoner

final class FileServiceTests: XCTestCase {
    func testValidateFilenameValidName() {
        XCTAssertEqual(FileService.validateFilename("test.txt"), "test.txt")
        XCTAssertEqual(FileService.validateFilename("my-file.md"), "my-file.md")
        XCTAssertEqual(FileService.validateFilename("file_name.swift"), "file_name.swift")
    }

    func testValidateFilenameTrimWhitespace() {
        XCTAssertEqual(FileService.validateFilename("  test.txt  "), "test.txt")
    }

    func testValidateFilenameEmpty() {
        XCTAssertNil(FileService.validateFilename(""))
        XCTAssertNil(FileService.validateFilename("   "))
    }

    func testValidateFilenamePathSeparators() {
        XCTAssertNil(FileService.validateFilename("path/file.txt"))
        XCTAssertNil(FileService.validateFilename("path\\file.txt"))
        XCTAssertNil(FileService.validateFilename("../file.txt"))
    }

    func testValidateFilenameSpecialChars() {
        XCTAssertNil(FileService.validateFilename("file\0.txt"))
        XCTAssertNil(FileService.validateFilename("file:name.txt"))
    }

    func testValidateFilenameUnicode() {
        XCTAssertEqual(FileService.validateFilename("文件.txt"), "文件.txt")
        XCTAssertEqual(FileService.validateFilename("emoji😀.txt"), "emoji😀.txt")
    }

    func testCreateFileSuccess() throws {
        let tempDir = FileManager.default.temporaryDirectory.path
        let filename = "test-\(UUID().uuidString).txt"

        let result = FileService.createFile(at: tempDir, named: filename)

        switch result {
        case .success(let url):
            XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
            try FileManager.default.removeItem(at: url)
        case .failure(let error):
            XCTFail("Failed: \(error)")
        }
    }

    func testCreateFileAlreadyExists() throws {
        let tempDir = FileManager.default.temporaryDirectory.path
        let filename = "test-\(UUID().uuidString).txt"
        let fullPath = (tempDir as NSString).appendingPathComponent(filename)

        FileManager.default.createFile(atPath: fullPath, contents: nil, attributes: nil)
        defer { try? FileManager.default.removeItem(atPath: fullPath) }

        let result = FileService.createFile(at: tempDir, named: filename)

        if case .failure = result {
            XCTAssertTrue(FileManager.default.fileExists(atPath: fullPath))
        } else {
            XCTFail("Should have failed with file exists error")
        }
    }
}
