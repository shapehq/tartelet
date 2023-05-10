import LogConsumer

final class LogConsumerMock: LogConsumer {
    var didLogError = false

    func info(_ message: StaticString, _ args: CVarArg...) {}

    func debug(_ message: StaticString, _ args: CVarArg...) {}

    func error(_ message: StaticString, _ args: CVarArg...) {
        didLogError = true
    }

    func fault(_ message: StaticString, _ args: CVarArg...) {}
}
