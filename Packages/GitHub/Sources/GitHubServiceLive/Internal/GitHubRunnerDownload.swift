import Foundation
import GitHubService

public struct GitHubRunnerDownload: Codable {
    private enum CodingKeys: String, CodingKey {
        case os
        case architecture
        case downloadURL = "download_url"
        case filename
    }

    let os: String
    let architecture: String
    public let downloadURL: URL
    public let filename: String
}
