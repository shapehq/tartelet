import Foundation

public protocol VirtualMachineSourceNameRepository {
    func sourceNames() async throws -> [String]
}
