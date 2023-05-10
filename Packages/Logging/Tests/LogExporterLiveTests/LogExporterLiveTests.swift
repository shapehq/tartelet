import LogExporterLive
import XCTest

final class LogExporterLiveTests: XCTestCase {
    func testItReadsMessagesFromLogStore() async throws {
        let fileSystem = FileSystemMock()
        let logStore = LogStoreMock()
        let logExporter = LogExporterLive(fileSystem: fileSystem, logStore: logStore)
        _ = try await logExporter.export()
        XCTAssertTrue(logStore.didReadMessages)
    }

    func testItCreatesTheParentDirectory() async throws {
        let fileSystem = FileSystemMock()
        let logStore = LogStoreMock()
        let logExporter = LogExporterLive(fileSystem: fileSystem, logStore: logStore)
        _ = try await logExporter.export()
        XCTAssertNotNil(fileSystem.createdDirectoryURL)
    }

    func testItWritesMessagesToDisk() async throws {
        let fileSystem = FileSystemMock()
        let logStore = LogStoreMock()
        let logExporter = LogExporterLive(fileSystem: fileSystem, logStore: logStore)
        _ = try await logExporter.export()
        XCTAssertNotNil(fileSystem.writtenFileURL)
    }

    func testWrittenMessagesIsSameAsMessagesInLogStore() async throws {
        let messages = "Hello world!"
        let expectedData = messages.data(using: .utf8, allowLossyConversion: false)!
        let fileSystem = FileSystemMock()
        let logStore = LogStoreMock(messages: messages)
        let logExporter = LogExporterLive(fileSystem: fileSystem, logStore: logStore)
        _ = try await logExporter.export()
        XCTAssertEqual(fileSystem.writtenData, expectedData)
    }

    func testItWritesToApplicationSupportDirectory() async throws {
        let fileSystem = FileSystemMock()
        let logStore = LogStoreMock()
        let logExporter = LogExporterLive(fileSystem: fileSystem, logStore: logStore)
        let fileURL = try await logExporter.export()
        XCTAssert(
            fileURL.absoluteString.hasPrefix(fileSystem.applicationSupportDirectoryURL.absoluteString),
            "File path should be within the Application Support directory"
        )
    }
}
