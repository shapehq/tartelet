public protocol LogConsumer {
    func info(_ message: StaticString, _ args: CVarArg...)
    func debug(_ message: StaticString, _ args: CVarArg...)
    func error(_ message: StaticString, _ args: CVarArg...)
    func fault(_ message: StaticString, _ args: CVarArg...)
}
