import XCTest
@testable import FileSummoner

final class FinderServiceTests: XCTestCase {
    func testGetActiveWindowPathReturnsPath() {
        let path = FinderService.getActiveWindowPath()
        XCTAssertNotNil(path)

        if let path = path {
            XCTAssertTrue(path.hasPrefix("/"))
            XCTAssertTrue(FileManager.default.fileExists(atPath: path))
        }
    }
}
