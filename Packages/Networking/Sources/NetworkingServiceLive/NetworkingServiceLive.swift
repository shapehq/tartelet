import Combine
import Foundation
import LogHelpers
import NetworkingService
import OSLog

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
    private let logger = Logger(category: "NetworkingServiceLive")
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
                let requestURL = request.url?.absoluteString ?? ""
                logger.info("Received invalid response for request to \(requestURL, privacy: .public)")
                let error: NetworkingServiceLiveError = .invalidResponse
                return .failure(withError: error)
            }
            guard (200 ... 299).contains(httpURLResponse.statusCode) else {
                let statusCode = httpURLResponse.statusCode
                let requestURL = request.url?.absoluteString ?? ""
                logger.info("Received unexpected status code \(statusCode, privacy: .public) for request to \(requestURL, privacy: .public)")
                let error: NetworkingServiceLiveError = .unexpectedStatusCode(httpURLResponse.statusCode)
                return .failure(withError: error, httpURLResponse: httpURLResponse)
            }
            return .success(with: data, httpURLResponse: httpURLResponse)
        } catch {
            let requestURL = request.url?.absoluteString ?? ""
            let errorMessage = error.localizedDescription
            logger.info("Request to \(requestURL, privacy: .public) failed: \(errorMessage, privacy: .public)")
            return .failure(withError: error)
        }
    }

    public func load<T: Decodable>(_ valueType: T.Type, from request: URLRequest) async -> NetworkResponse<T> {
        return await data(from: request).map { parameters in
            do {
                let value = try decoder.decode(T.self, from: parameters.value)
                return .success(with: value, httpURLResponse: parameters.httpURLResponse)
            } catch {
                let requestURL = request.url?.absoluteString ?? ""
                let errorMessage = error.localizedDescription
                logger.info("Failed decoing response from request to \(requestURL, privacy: .public): \(errorMessage, privacy: .public)")
                throw error
            }
        }
    }
}
