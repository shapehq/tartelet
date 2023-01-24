import Foundation

public enum NetworkResponse<T> {
    public struct SuccessParameters {
        public let value: T
        public let httpURLResponse: HTTPURLResponse?
    }

    public struct FailureParameters {
        public let error: Error
        public let httpURLResponse: HTTPURLResponse?
    }

    case success(SuccessParameters)
    case failure(FailureParameters)

    public var httpURLResponse: HTTPURLResponse? {
        switch self {
        case .success(let parameters):
            return parameters.httpURLResponse
        case .failure(let parameters):
            return parameters.httpURLResponse
        }
    }

    public static func success(with value: T, httpURLResponse: HTTPURLResponse? = nil) -> Self {
        let parameters = SuccessParameters(value: value, httpURLResponse: httpURLResponse)
        return .success(parameters)
    }

    public static func failure(withError error: Error, httpURLResponse: HTTPURLResponse? = nil) -> Self {
        let parameters = FailureParameters(error: error, httpURLResponse: httpURLResponse)
        return .failure(parameters)
    }

    public func map<U>(handler: (SuccessParameters) throws -> U) throws -> U {
        switch self {
        case .success(let parameters):
            return try handler(parameters)
        case .failure(let parameters):
            throw parameters.error
        }
    }

    public func map<U>(_ keyPath: KeyPath<SuccessParameters, U>) throws -> U {
        try map { $0[keyPath: keyPath] }
    }

    public func map<U>(handler: (SuccessParameters) throws -> NetworkResponse<U>) -> NetworkResponse<U> {
        switch self {
        case .success(let parameters):
            do {
                return try handler(parameters)
            } catch {
                return .failure(withError: error, httpURLResponse: parameters.httpURLResponse)
            }
        case .failure(let parameters):
            return .failure(withError: parameters.error, httpURLResponse: parameters.httpURLResponse)
        }
    }
}
