import Combine
import Foundation
import LogConsumer
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
    private let logger: LogConsumer
    private let session: URLSession
    private let decoder: JSONDecoder

    public init(logger: LogConsumer, session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.logger = logger
        self.session = session
        self.decoder = decoder
    }

    public func data(from request: URLRequest) async -> NetworkResponse<Data> {
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpURLResponse = response as? HTTPURLResponse else {
                logger.info("Received invalid response for request to %@", request.url?.absoluteString ?? "")
                let error: NetworkingServiceLiveError = .invalidResponse
                return .failure(withError: error)
            }
            guard (200 ... 299).contains(httpURLResponse.statusCode) else {
                logger.info("Received unexpected status code %d for request to %@", httpURLResponse.statusCode, request.url?.absoluteString ?? "")
                let error: NetworkingServiceLiveError = .unexpectedStatusCode(httpURLResponse.statusCode)
                return .failure(withError: error, httpURLResponse: httpURLResponse)
            }
            return .success(with: data, httpURLResponse: httpURLResponse)
        } catch {
            logger.info("Request to %@ failed: %@", request.url?.absoluteString ?? "", error.localizedDescription)
            return .failure(withError: error)
        }
    }

    public func load<T: Decodable>(_ valueType: T.Type, from request: URLRequest) async -> NetworkResponse<T> {
        return await data(from: request).map { parameters in
            do {
                let value = try decoder.decode(T.self, from: parameters.value)
                return .success(with: value, httpURLResponse: parameters.httpURLResponse)
            } catch {
                logger.info("Failed decoing response from request to %@: %@", request.url?.absoluteString ?? "", error.localizedDescription)
                throw error
            }
        }
    }
}
