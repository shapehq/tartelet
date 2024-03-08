import FileSystemDomain
import Foundation

struct LogsDirectory {
    let fileSystem: FileSystem
    var url: URL {
        fileSystem.applicationSupportDirectoryURL.appending(
            component: "Logs",
            directoryHint: .isDirectory
        )
    }
}
