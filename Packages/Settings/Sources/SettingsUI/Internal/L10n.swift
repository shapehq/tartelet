// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum Settings {
    /// General
    internal static let general = L10n.tr("Localizable", "settings.general", fallback: "General")
    /// GitHub
    internal static let github = L10n.tr("Localizable", "settings.github", fallback: "GitHub")
    /// Runner
    internal static let githubRunner = L10n.tr("Localizable", "settings.github_runner", fallback: "Runner")
    /// Virtual Machine
    internal static let virtualMachine = L10n.tr("Localizable", "settings.virtual_machine", fallback: "Virtual Machine")
    internal enum General {
      /// Show In
      internal static let applicationUiMode = L10n.tr("Localizable", "settings.general.application_ui_mode", fallback: "Show In")
      /// Export Logs...
      internal static let exportLogs = L10n.tr("Localizable", "settings.general.export_logs", fallback: "Export Logs...")
      internal enum ApplicationUiMode {
        /// Dock
        internal static let dock = L10n.tr("Localizable", "settings.general.application_ui_mode.dock", fallback: "Dock")
        /// Dock and Menu Bar
        internal static let dockAndMenuBar = L10n.tr("Localizable", "settings.general.application_ui_mode.dock_and_menu_bar", fallback: "Dock and Menu Bar")
        /// Menu Bar
        internal static let menuBar = L10n.tr("Localizable", "settings.general.application_ui_mode.menu_bar", fallback: "Menu Bar")
      }
    }
    internal enum Github {
      /// App ID
      internal static let appId = L10n.tr("Localizable", "settings.github.app_id", fallback: "App ID")
      /// Create GitHub App
      internal static let createApp = L10n.tr("Localizable", "settings.github.create_app", fallback: "Create GitHub App")
      /// Organization Name
      internal static let organizationName = L10n.tr("Localizable", "settings.github.organization_name", fallback: "Organization Name")
      /// Owner name
      internal static let ownerName = L10n.tr("Localizable", "settings.github.owner_name", fallback: "Owner name")
      /// Private Key (PEM)
      internal static let privateKey = L10n.tr("Localizable", "settings.github.private_key", fallback: "Private Key (PEM)")
      /// Repository name
      internal static let repositoryName = L10n.tr("Localizable", "settings.github.repository_name", fallback: "Repository name")
      /// Runner scope
      internal static let runnerScope = L10n.tr("Localizable", "settings.github.runner_scope", fallback: "Runner scope")
      internal enum PrivateKey {
        /// Select a private key (PEM)
        internal static let placeholder = L10n.tr("Localizable", "settings.github.private_key.placeholder", fallback: "Select a private key (PEM)")
        /// The private key must have these scopes set:
        /// ✔ Self-hosted runners (Read and write)
        internal static let scopes = L10n.tr("Localizable", "settings.github.private_key.scopes", fallback: "The private key must have these scopes set:\n✔ Self-hosted runners (Read and write)")
        /// Select File
        internal static let selectFile = L10n.tr("Localizable", "settings.github.private_key.select_file", fallback: "Select File")
      }
    }
    internal enum GithubRunner {
      /// Group
      internal static let group = L10n.tr("Localizable", "settings.github_runner.group", fallback: "Group")
      /// Labels
      internal static let labels = L10n.tr("Localizable", "settings.github_runner.labels", fallback: "Labels")
      internal enum Group {
        /// Name of the runner group.
        internal static let footer = L10n.tr("Localizable", "settings.github_runner.group.footer", fallback: "Name of the runner group.")
      }
      internal enum Labels {
        /// Comma-separated list of labels.
        internal static let footer = L10n.tr("Localizable", "settings.github_runner.labels.footer", fallback: "Comma-separated list of labels.")
      }
    }
    internal enum VirtualMachine {
      /// Amount
      internal static let count = L10n.tr("Localizable", "settings.virtual_machine.count", fallback: "Amount")
      /// Use the Tart CLI to create a virtual machine.
      internal static let noVirtualMachinesAvailable = L10n.tr("Localizable", "settings.virtual_machine.no_virtual_machines_available", fallback: "Use the Tart CLI to create a virtual machine.")
      /// Start Virtual Machines on App Launch
      internal static let startVirtualMachinesOnAppLaunch = L10n.tr("Localizable", "settings.virtual_machine.start_virtual_machines_on_app_launch", fallback: "Start Virtual Machines on App Launch")
      /// Tart Home
      internal static let tartHomeFolder = L10n.tr("Localizable", "settings.virtual_machine.tart_home_folder", fallback: "Tart Home")
      /// Unknown
      internal static let unknown = L10n.tr("Localizable", "settings.virtual_machine.unknown", fallback: "Unknown")
      internal enum Count {
        /// One
        internal static let one = L10n.tr("Localizable", "settings.virtual_machine.count.one", fallback: "One")
        /// Two
        internal static let two = L10n.tr("Localizable", "settings.virtual_machine.count.two", fallback: "Two")
      }
      internal enum TartHomeFolder {
        /// Value of the TART_HOME environment variable.
        internal static let footer = L10n.tr("Localizable", "settings.virtual_machine.tart_home_folder.footer", fallback: "Value of the TART_HOME environment variable.")
        /// ~/.tart
        internal static let placeholder = L10n.tr("Localizable", "settings.virtual_machine.tart_home_folder.placeholder", fallback: "~/.tart")
        /// Reset to Default
        internal static let resetToDefault = L10n.tr("Localizable", "settings.virtual_machine.tart_home_folder.reset_to_default", fallback: "Reset to Default")
        /// Select Folder
        internal static let selectFolder = L10n.tr("Localizable", "settings.virtual_machine.tart_home_folder.select_folder", fallback: "Select Folder")
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
