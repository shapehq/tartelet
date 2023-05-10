import LogStore

final class LogStoreMock: LogStore {
    private(set) var didReadMessages = false

    private var messages: String

    init(messages: String = "Hello world!") {
        self.messages = messages
    }

    func readMessages() throws -> String {
        didReadMessages = true
        return messages
    }
}
