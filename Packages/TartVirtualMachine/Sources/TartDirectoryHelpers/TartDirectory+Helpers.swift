import Foundation
import Tart

public extension Tart.Directory {
    static func resources(at directoryURL: URL) -> Tart.Directory {
        return Self(name: "Resources", directoryURL: directoryURL)
    }
}
