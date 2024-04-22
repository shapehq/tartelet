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
            process.launch()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()
            guard process.terminationStatus == 0 else {
                throw ProcessShellError.unexpectedTerminationStatus(process.terminationStatus)
            }
            return String(data: data, encoding: .utf8) ?? ""
        } onCancel: {
            if sendableProcess.process.isRunning {
                sendableProcess.process.terminate()
            }
        }
    }
}
