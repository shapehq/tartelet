import Foundation

public enum GitHubServiceVersion {
  case dotCom
  case enterprise(URL)

  public enum Kind: String, CaseIterable {
    case dotCom
    case enterprise
  }
}
