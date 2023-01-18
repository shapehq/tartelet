import Foundation

extension NSFileCoordinator {
    static func coordinateWritingItem(at fileURL: URL, options: NSFileCoordinator.WritingOptions = [], handler: (URL) throws -> Void) throws {
        let coordinator = NSFileCoordinator()
        var coordinationError: NSError?
        var writeError: Error?
        coordinator.coordinate(writingItemAt: fileURL, options: options, error: &coordinationError) { safeFileURL in
            do {
                try handler(safeFileURL)
            } catch {
                writeError = error
            }
        }
        if let coordinationError {
            throw coordinationError
        } else if let writeError = writeError {
            throw writeError
        }
    }

    static func coordinateReadingItem<T>(
        at fileURL: URL,
        options: NSFileCoordinator.ReadingOptions = [],
        handler: (URL) throws -> T
    ) throws -> T {
        let coordinator = NSFileCoordinator()
        var coordinationError: NSError?
        var readError: Error?
        var value: T?
        coordinator.coordinate(readingItemAt: fileURL, options: options, error: &coordinationError) { safeFileURL in
            do {
                value = try handler(safeFileURL)
            } catch {
                readError = error
            }
        }
        if let coordinationError {
            throw coordinationError
        } else if let writeError = readError {
            throw writeError
        } else {
            return value!
        }
    }

    static func coordinateReadingItem<T>(
        at readingFileURL: URL,
        options readingOptions: NSFileCoordinator.ReadingOptions = [],
        writingTo writingFileURL: URL,
        options writingOptions: NSFileCoordinator.WritingOptions = [],
        handler: (URL, URL) throws -> T
    ) throws -> T {
        let coordinator = NSFileCoordinator()
        var coordinationError: NSError?
        var readError: Error?
        var value: T?
        coordinator.coordinate(
            readingItemAt: readingFileURL,
            options: readingOptions,
            writingItemAt: writingFileURL,
            options: writingOptions,
            error: &coordinationError
        ) { safeReadingFileURL, safeWritingFileURL in
            do {
                value = try handler(safeReadingFileURL, safeWritingFileURL)
            } catch {
                readError = error
            }
        }
        if let coordinationError {
            throw coordinationError
        } else if let writeError = readError {
            throw writeError
        } else {
            return value!
        }
    }
}
