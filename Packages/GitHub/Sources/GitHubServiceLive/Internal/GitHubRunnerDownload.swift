import Foundation

public struct GitHubRunnerDownload: Codable {
    private enum CodingKeys: String, CodingKey {
        case os
        case architecture
        case downloadURL = "download_url"
    }

    let os: String
    let architecture: String
    let downloadURL: URL
}
