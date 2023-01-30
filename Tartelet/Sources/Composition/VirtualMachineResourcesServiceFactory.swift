import VirtualMachineResourcesService

protocol VirtualMachineResourcesServiceFactory {
    func makeService(virtualMachineName: String) -> VirtualMachineResourcesService
}
