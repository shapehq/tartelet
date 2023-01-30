import AppKit
import Foundation

public protocol VirtualMachineResourcesService {
    var directoryURL: URL { get }
    func createResourcesIfNeeded() async throws
    func removeResources() throws
    func openDirectory() throws
}

public extension VirtualMachineResourcesService {
    func openDirectory() throws {
        NSWorkspace.shared.open(directoryURL)
    }
}
