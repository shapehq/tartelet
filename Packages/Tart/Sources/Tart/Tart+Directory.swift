import Foundation

public extension Tart {
    struct Directory {
        public let name: String
        private let url: URL

        public init(name: String, url: URL) {
            self.name = name
            self.url = url
        }

        public var pathOrURL: String {
            if url.isFileURL {
                url.path
            } else {
                url.absoluteString
            }
        }
    }
}
