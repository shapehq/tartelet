// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum Menu {
    internal enum VirtualMachines {
      /// Virtual Machines
      internal static let pluralis = L10n.tr("Localizable", "menu.virtual_machines.pluralis", fallback: "Virtual Machines")
      /// Virtual Machine
      internal static let singularis = L10n.tr("Localizable", "menu.virtual_machines.singularis", fallback: "Virtual Machine")
    }
  }
  internal enum MenuBarItem {
    /// About...
    internal static let about = L10n.tr("Localizable", "menu_bar_item.about", fallback: "About...")
    /// Quit
    internal static let quit = L10n.tr("Localizable", "menu_bar_item.quit", fallback: "Quit")
    /// Settings...
    internal static let settings = L10n.tr("Localizable", "menu_bar_item.settings", fallback: "Settings...")
    internal enum Editor {
      internal enum EditVirtualMachine {
        /// Editing...
        internal static let editing = L10n.tr("Localizable", "menu_bar_item.editor.edit_virtual_machine.editing", fallback: "Editing...")
        /// Edit Virtual Machine
        internal static let start = L10n.tr("Localizable", "menu_bar_item.editor.edit_virtual_machine.start", fallback: "Edit Virtual Machine")
      }
    }
    internal enum VirtualMachines {
      /// Start
      internal static let start = L10n.tr("Localizable", "menu_bar_item.virtual_machines.start", fallback: "Start")
      /// Stop
      internal static let stop = L10n.tr("Localizable", "menu_bar_item.virtual_machines.stop", fallback: "Stop")
      /// Stopping...
      internal static let stopping = L10n.tr("Localizable", "menu_bar_item.virtual_machines.stopping", fallback: "Stopping...")
      /// Stops when virtual machines have terminated.
      internal static let stoppingInfo = L10n.tr("Localizable", "menu_bar_item.virtual_machines.stopping_info", fallback: "Stops when virtual machines have terminated.")
      /// Select Virtual Machine...
      internal static let unavailable = L10n.tr("Localizable", "menu_bar_item.virtual_machines.unavailable", fallback: "Select Virtual Machine...")
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
