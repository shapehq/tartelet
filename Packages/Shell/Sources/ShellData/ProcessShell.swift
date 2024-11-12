import Foundation
import ShellDomain

public struct ProcessShell: Shell {
    public init() {}

    public func runExecutable(
        atPath executablePath: String,
        withArguments arguments: [String],
        environment: [String: String]
    ) async throws -> String {
        let process = Process()
        let sendableProcess = SendableProcess(process)
        return try await withTaskCancellationHandler {
            let pipe = Pipe()
            process.standardOutput = pipe
            process.arguments = arguments
            process.launchPath = executablePath
            process.standardInput = nil
            process.environment = environment
            process.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            // Explicitly close the pipe file handle to prevent running
            // out of file descriptors.
            // See https://github.com/swiftlang/swift/issues/57827
            try! pipe.fileHandleForReading.close()
            process.waitUntilExit()
            guard process.terminationStatus == 0 else {
                throw ProcessShellError.unexpectedTerminationStatus(process.terminationStatus)
            }
            return String(decoding: data, as: UTF8.self)
        } onCancel: {
            if sendableProcess.process.isRunning {
                sendableProcess.process.terminate()
            }
        }
    }
}
