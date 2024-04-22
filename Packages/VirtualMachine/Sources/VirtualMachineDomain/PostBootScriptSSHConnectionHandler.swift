import SSHDomain

public struct PostBootScriptSSHConnectionHandler: VirtualMachineSSHConnectionHandler {
    public init() {}

    public func didConnect(to virtualMachine: VirtualMachine, through connection: SSHConnection) async throws {
        try await connection.executeCommand("""
export RUNNER_NAME=\(virtualMachine.name)
POST_BOOT_SCRIPT_PATH="$HOME/.tartelet/post-boot.sh"
if [ -f "$POST_BOOT_SCRIPT_PATH" ]; then
  sh $POST_BOOT_SCRIPT_PATH
fi
""")
    }
}
