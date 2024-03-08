import Foundation

public protocol LogExporter {
    func export() async throws
}
