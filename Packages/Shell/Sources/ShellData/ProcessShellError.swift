import Foundation

public enum ProcessShellError: LocalizedError {
   case unexpectedTerminationStatus(Int32)

   public var errorDescription: String? {
       switch self {
       case .unexpectedTerminationStatus(let terminationStatus):
            "Unexpected termination status: \(terminationStatus)"
       }
   }
}
