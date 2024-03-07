import Foundation

public protocol VirtualMachine {
    var name: String { get }
    func start() async throws
    func clone(named newName: String) async throws -> VirtualMachine
    func delete() async throws
}
