// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum Settings {
    internal enum ConfigurationState {
      internal enum MissingGithubAppId {
        /// Set GitHub App ID...
        internal static let shortInstruction = L10n.tr("Localizable", "settings.configuration_state.missing_github_app_id.short_instruction", fallback: "Set GitHub App ID...")
      }
      internal enum MissingGithubOrganizationName {
        /// Set GitHub Organization Name...
        internal static let shortInstruction = L10n.tr("Localizable", "settings.configuration_state.missing_github_organization_name.short_instruction", fallback: "Set GitHub Organization Name...")
      }
      internal enum MissingGithubOwnerName {
        /// Set GitHub Owner Name...
        internal static let shortInstruction = L10n.tr("Localizable", "settings.configuration_state.missing_github_owner_name.short_instruction", fallback: "Set GitHub Owner Name...")
      }
      internal enum MissingGithubPrivateKey {
        /// Set GitHub Private Key...
        internal static let shortInstruction = L10n.tr("Localizable", "settings.configuration_state.missing_github_private_key.short_instruction", fallback: "Set GitHub Private Key...")
      }
      internal enum MissingGithubRepositoryName {
        /// Set GitHub Repository Name...
        internal static let shortInstruction = L10n.tr("Localizable", "settings.configuration_state.missing_github_repository_name.short_instruction", fallback: "Set GitHub Repository Name...")
      }
      internal enum MissingSshCredentials {
        /// Set SSH Credentials...
        internal static let shortInstruction = L10n.tr("Localizable", "settings.configuration_state.missing_ssh_credentials.short_instruction", fallback: "Set SSH Credentials...")
      }
      internal enum MissingVirtualMachine {
        /// Select Virtual Machine...
        internal static let shortInstruction = L10n.tr("Localizable", "settings.configuration_state.missing_virtual_machine.short_instruction", fallback: "Select Virtual Machine...")
      }
      internal enum Ready {
        /// Ready
        internal static let shortInstruction = L10n.tr("Localizable", "settings.configuration_state.ready.short_instruction", fallback: "Ready")
      }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
