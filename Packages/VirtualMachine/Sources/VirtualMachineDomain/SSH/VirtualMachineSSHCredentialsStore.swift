public protocol VirtualMachineSSHCredentialsStore {
    var username: String? { get }
    var password: String? { get }
    func setUsername(_ username: String?)
    func setPassword(_ password: String?)
}
