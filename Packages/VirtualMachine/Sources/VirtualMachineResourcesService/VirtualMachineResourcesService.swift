import Foundation

public protocol VirtualMachineResourcesService {
    var directoryURL: URL { get }
    func createResourcesIfNeeded() throws
}
