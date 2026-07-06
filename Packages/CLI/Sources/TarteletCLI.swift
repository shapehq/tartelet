import ArgumentParser
import Composers
import Foundation
import SettingsDomain
import ShellData
import VirtualMachineData

@main
struct TarteletCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "tartelet",
        abstract: "Manage Tartelet settings and Tart virtual machines.",
        subcommands: [
            Status.self,
            List.self,
            Select.self,
            Start.self,
            Stop.self,
            Restart.self,
            IP.self,
        ]
    )
}

private struct Status: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Print the configured Tartelet VM settings."
    )

    func run() async throws {
        let settings = Composers.settingsStore
        let selectedVirtualMachine = settings.selectedVirtualMachineName ?? "none"
        let tartHome = settings.tartHomeFolderURL?.path(percentEncoded: false) ?? "default"

        print("selected_vm: \(selectedVirtualMachine)")
        print("number_of_vms: \(settings.numberOfVirtualMachines)")
        print("start_on_launch: \(settings.startVirtualMachinesOnLaunch)")
        print("tart_home: \(tartHome)")
        print("runner_labels: \(settings.gitHubRunnerLabels)")
        print("runner_group: \(settings.gitHubRunnerGroup)")
        print("runner_scope: \(settings.githubRunnerScope.rawValue)")
    }
}

private struct List: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "List local Tart virtual machines."
    )

    func run() async throws {
        let settings = Composers.settingsStore
        let selectedName = settings.selectedVirtualMachineName
        let virtualMachines = try await makeTart().list()

        for virtualMachine in virtualMachines {
            if virtualMachine == selectedName {
                print("* \(virtualMachine)")
            } else {
                print("  \(virtualMachine)")
            }
        }
    }
}

private struct Select: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Select the base Tart VM used by Tartelet."
    )

    @Argument(help: "The local Tart VM name to use as Tartelet's base VM.")
    var name: String

    mutating func run() throws {
        Composers.settingsStore.virtualMachine = .virtualMachine(name)
        print("selected_vm: \(name)")
    }
}

private struct Start: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Start a Tart VM."
    )

    @Option(help: "The Tart VM name. Defaults to the VM selected in Tartelet settings.")
    var name: String?

    @Flag(help: "Stay attached until the VM stops.")
    var attach = false

    func run() async throws {
        let virtualMachineName = try resolvedVirtualMachineName(name)
        let tart = makeTart()

        if attach {
            print("starting: \(virtualMachineName)")
            try await tart.run(name: virtualMachineName)
        } else {
            try tart.runDetached(name: virtualMachineName)
            print("started: \(virtualMachineName)")
        }
    }
}

private struct Stop: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Stop a running Tart VM."
    )

    @Option(help: "The Tart VM name. Defaults to the VM selected in Tartelet settings.")
    var name: String?

    func run() async throws {
        let virtualMachineName = try resolvedVirtualMachineName(name)
        try await makeTart().stop(name: virtualMachineName)
        print("stopped: \(virtualMachineName)")
    }
}

private struct Restart: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Stop and then start a Tart VM."
    )

    @Option(help: "The Tart VM name. Defaults to the VM selected in Tartelet settings.")
    var name: String?

    @Flag(help: "Stay attached after restarting until the VM stops.")
    var attach = false

    func run() async throws {
        let virtualMachineName = try resolvedVirtualMachineName(name)
        let tart = makeTart()

        print("stopping: \(virtualMachineName)")
        try await tart.stop(name: virtualMachineName)
        if attach {
            print("starting: \(virtualMachineName)")
            try await tart.run(name: virtualMachineName)
        } else {
            try tart.runDetached(name: virtualMachineName)
            print("started: \(virtualMachineName)")
        }
    }
}

private struct IP: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "ip",
        abstract: "Print a Tart VM's current IP address."
    )

    @Option(help: "The Tart VM name. Defaults to the VM selected in Tartelet settings.")
    var name: String?

    func run() async throws {
        let virtualMachineName = try resolvedVirtualMachineName(name)
        let ipAddress = try await makeTart().getIPAddress(ofVirtualMachineNamed: virtualMachineName)
        print(ipAddress)
    }
}

private func makeTart() -> Tart {
    Tart(
        homeProvider: SettingsTartHomeProvider(
            settingsStore: Composers.settingsStore
        ),
        shell: ProcessShell()
    )
}

private func resolvedVirtualMachineName(_ explicitName: String?) throws -> String {
    if let explicitName {
        return explicitName
    }
    if let selectedName = Composers.settingsStore.selectedVirtualMachineName {
        return selectedName
    }
    throw ValidationError("No VM name was provided and no VM is selected in Tartelet settings.")
}

private extension SettingsStore {
    var selectedVirtualMachineName: String? {
        switch virtualMachine {
        case .unknown:
            return nil
        case let .virtualMachine(name):
            return name
        }
    }
}
