import Combine
import Foundation
import NetworkingService

private enum NetworkingServiceLiveError: LocalizedError {
    case invalidResponse
    case unexpectedStatusCode(Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Expected valid HTTP response"
        case .unexpectedStatusCode(let statusCode):
            return "Received unexpected status code: \(statusCode)"
        }
    }
}

public struct NetworkingServiceLive: NetworkingService {
    private let session: URLSession
    private let decoder: JSONDecoder

    public init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    public func data(from request: URLRequest) async -> NetworkResponse<Data> {
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpURLResponse = response as? HTTPURLResponse else {
                let error: NetworkingServiceLiveError = .invalidResponse
                return .failure(withError: error)
            }
            guard (200 ... 299).contains(httpURLResponse.statusCode) else {
                let error: NetworkingServiceLiveError = .unexpectedStatusCode(httpURLResponse.statusCode)
                return .failure(withError: error, httpURLResponse: httpURLResponse)
            }
            return .success(with: data, httpURLResponse: httpURLResponse)
        } catch {
            return .failure(withError: error)
        }
    }

    public func load<T: Decodable>(_ valueType: T.Type, from request: URLRequest) async -> NetworkResponse<T> {
        return await data(from: request).map { parameters in
            let value = try decoder.decode(T.self, from: parameters.value)
            return .success(with: value, httpURLResponse: parameters.httpURLResponse)
        }
    }
}
