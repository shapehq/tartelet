import Foundation

final actor DestinationVMNameFactory {
    private var count = 1

    func destinationVMName(fromSourceName sourceVMName: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd HHmmss"
        let dateString = dateFormatter.string(from: Date())
        let destinationVMName = sourceVMName + " " + dateString + " (\(count))"
        count += 1
        return destinationVMName
    }
}
