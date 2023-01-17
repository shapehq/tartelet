// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum MenuBarItem {
    /// About...
    internal static let about = L10n.tr("Localizable", "menu_bar_item.about", fallback: "About...")
    /// Quit
    internal static let quit = L10n.tr("Localizable", "menu_bar_item.quit", fallback: "Quit")
    /// Settings...
    internal static let settings = L10n.tr("Localizable", "menu_bar_item.settings", fallback: "Settings...")
    internal enum VirtualMachines {
      /// Select Virtual Machine...
      internal static let missing = L10n.tr("Localizable", "menu_bar_item.virtual_machines.missing", fallback: "Select Virtual Machine...")
      internal enum Start {
        /// Start Virtual Machines
        internal static let pluralis = L10n.tr("Localizable", "menu_bar_item.virtual_machines.start.pluralis", fallback: "Start Virtual Machines")
        /// Start Virtual Machine
        internal static let singularis = L10n.tr("Localizable", "menu_bar_item.virtual_machines.start.singularis", fallback: "Start Virtual Machine")
      }
      internal enum Stop {
        /// Stop Virtual Machines
        internal static let pluralis = L10n.tr("Localizable", "menu_bar_item.virtual_machines.stop.pluralis", fallback: "Stop Virtual Machines")
        /// Stop Virtual Machine
        internal static let singularis = L10n.tr("Localizable", "menu_bar_item.virtual_machines.stop.singularis", fallback: "Stop Virtual Machine")
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
