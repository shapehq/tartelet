import Foundation

public extension Tart {
    struct Directory {
        public let name: String
        public let directoryURL: URL

        public init(name: String, directoryURL: URL) {
            self.name = name
            self.directoryURL = directoryURL
        }
    }
}
