import Foundation
import Shell

enum TartLocatorError: LocalizedError {
    case notFound

    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Tart could not be found"
        }
    }
}

struct TartLocator {
    let shell: Shell

    init(shell: Shell) {
        self.shell = shell
    }

    func locate() throws -> String {
        let candidates = ["/opt/homebrew/bin/tart"]
        let fileManager: FileManager = .default
        guard let filePath = candidates.first(where: { fileManager.fileExists(atPath: $0) }) else {
            throw TartLocatorError.notFound
        }
        return filePath
    }
}
