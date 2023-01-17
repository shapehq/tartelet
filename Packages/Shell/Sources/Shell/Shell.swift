import Combine
import Foundation

public enum ShellError: LocalizedError {
    case unexpectedTerminationStatus(Int32)

    public var errorDescription: String? {
        switch self {
        case .unexpectedTerminationStatus(let terminationStatus):
            return "Unexpected termination status: \(terminationStatus)"
        }
    }
}

public struct Shell {
    public init() {}

    @discardableResult
    public func runExecutable(atPath executablePath: String, withArguments arguments: [String]) async throws -> String {
        let process = Process()
        let sendableProcess = SendableProcess(process)
        return try await withTaskCancellationHandler {
            let pipe = Pipe()
            process.standardOutput = pipe
            process.arguments = arguments
            process.launchPath = executablePath
            process.standardInput = nil
            process.launch()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()
            guard process.terminationStatus == 0 else {
                throw ShellError.unexpectedTerminationStatus(process.terminationStatus)
            }
            return String(data: data, encoding: .utf8) ?? ""
        } onCancel: {
            sendableProcess.process.terminate()
        }
    }
}

private final class SendableProcess: @unchecked Sendable {
    let process: Process

    init(_ process: Process) {
        self.process = process
    }
}
