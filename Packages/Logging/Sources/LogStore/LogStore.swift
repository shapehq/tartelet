import Foundation

public protocol LogStore {
    func readMessages() throws -> String
}
