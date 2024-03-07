import Combine
import Foundation
import LoggingDomain
import NetworkingDomain

private enum URLSessionNetworkingServiceError: LocalizedError {
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

public struct URLSessionNetworkingService: NetworkingService {
    private let logger: Logger
    private let session: URLSession
    private let decoder: JSONDecoder

    public init(
        logger: Logger,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.logger = logger
        self.session = session
        self.decoder = decoder
    }

    public func data(from request: URLRequest) async -> NetworkResponse<Data> {
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpURLResponse = response as? HTTPURLResponse else {
                let requestURL = request.url?.absoluteString ?? ""
                logger.info("Received invalid response for request to \(requestURL)")
                let error: URLSessionNetworkingServiceError = .invalidResponse
                return .failure(withError: error)
            }
            guard (200 ... 299).contains(httpURLResponse.statusCode) else {
                let statusCode = httpURLResponse.statusCode
                let requestURL = request.url?.absoluteString ?? ""
                logger.info("Received unexpected status code \(statusCode) for request to \(requestURL)")
                let error: URLSessionNetworkingServiceError = .unexpectedStatusCode(httpURLResponse.statusCode)
                return .failure(withError: error, httpURLResponse: httpURLResponse)
            }
            return .success(with: data, httpURLResponse: httpURLResponse)
        } catch {
            let requestURL = request.url?.absoluteString ?? ""
            let errorMessage = error.localizedDescription
            logger.info("Request to \(requestURL) failed: \(errorMessage)")
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
                logger.info("Failed decoing response from request to \(requestURL): \(errorMessage)")
                throw error
            }
        }
    }
}
