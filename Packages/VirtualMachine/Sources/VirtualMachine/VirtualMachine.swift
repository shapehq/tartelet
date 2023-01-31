import Foundation

public protocol VirtualMachine {
    var name: String { get }
    func start() async throws
    func stop() async throws
}
