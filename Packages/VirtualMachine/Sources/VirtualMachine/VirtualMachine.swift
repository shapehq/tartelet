import Foundation

public protocol VirtualMachine {
    func start() async throws
    func stop() async throws
}
