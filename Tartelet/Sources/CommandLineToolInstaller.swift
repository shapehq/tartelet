import AppKit
import Foundation

@MainActor
enum CommandLineToolInstaller {
    private static let executableName = "tartelet"

    static func install() {
        do {
            let installedURL = try installCommandLineTool()
            showSuccess(installedURL: installedURL)
        } catch {
            showFailure(error: error)
        }
    }
}

private extension CommandLineToolInstaller {
    enum InstallerError: LocalizedError {
        case bundledToolNotFound(URL)

        var errorDescription: String? {
            switch self {
            case .bundledToolNotFound(let expectedURL):
                return "The bundled command line tool could not be found at \(expectedURL.path(percentEncoded: false))."
            }
        }
    }

    static func installCommandLineTool() throws -> URL {
        let sourceURL = try bundledCommandLineToolURL()
        let installDirectoryURL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".local/bin", isDirectory: true)
        let installedURL = installDirectoryURL.appendingPathComponent(executableName)

        try FileManager.default.createDirectory(
            at: installDirectoryURL,
            withIntermediateDirectories: true
        )
        if FileManager.default.fileExists(atPath: installedURL.path(percentEncoded: false)) {
            try FileManager.default.removeItem(at: installedURL)
        }
        try FileManager.default.copyItem(at: sourceURL, to: installedURL)
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o755],
            ofItemAtPath: installedURL.path(percentEncoded: false)
        )

        return installedURL
    }

    static func bundledCommandLineToolURL() throws -> URL {
        if let url = Bundle.main.url(forAuxiliaryExecutable: executableName) {
            return url
        }

        let expectedURL = Bundle.main.bundleURL
            .appendingPathComponent("Contents/Helpers", isDirectory: true)
            .appendingPathComponent(executableName)
        guard FileManager.default.isExecutableFile(atPath: expectedURL.path(percentEncoded: false)) else {
            throw InstallerError.bundledToolNotFound(expectedURL)
        }
        return expectedURL
    }

    static func showSuccess(installedURL: URL) {
        let installedPath = installedURL.path(percentEncoded: false)
        let installDirectoryPath = installedURL
            .deletingLastPathComponent()
            .path(percentEncoded: false)
        let pathContainsInstallDirectory = ProcessInfo.processInfo.environment["PATH"]?
            .split(separator: ":")
            .contains(Substring(installDirectoryPath)) ?? false

        let alert = NSAlert()
        alert.messageText = "Command Line Tool Installed"
        if pathContainsInstallDirectory {
            alert.informativeText = "\(executableName) was installed at \(installedPath)."
        } else {
            alert.informativeText = """
            \(executableName) was installed at \(installedPath).

            If your shell cannot find it, add \(installDirectoryPath) to your PATH.
            """
        }
        alert.addButton(withTitle: "Done")
        alert.runModal()
    }

    static func showFailure(error: Error) {
        let alert = NSAlert(error: error)
        alert.messageText = "Could Not Install Command Line Tool"
        alert.runModal()
    }
}
