import AppKit
import Foundation

public protocol VirtualMachineResourcesService {
    var directoryURL: URL { get }
    func createResourcesIfNeeded() throws
    func openDirectory() throws
}

public extension VirtualMachineResourcesService {
    func openDirectory() throws {
        try createResourcesIfNeeded()
        NSWorkspace.shared.open(directoryURL)
    }
}
