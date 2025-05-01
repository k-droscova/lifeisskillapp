//
//  Network.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.07.2024.
//

import Foundation

protocol HasNetwork {
    var network: Networking { get }
}

protocol Networking {
    func performRequest<T: Decodable, E: APIResponseErroring>(
        url: URL,
        method: Network.HTTPMethod,
        headers: [String: String]?,
        body: Data?,
        sensitiveRequestBodyData: Bool,
        errorObject: E.Type
    ) async throws -> T
}

extension Networking {
    func performAuthorizedRequest<T: Decodable, E: APIResponseErroring>(
        endpoint: Endpointing,
        method: Network.HTTPMethod = .GET,
        body: Data? = nil,
        sensitiveRequestBodyData: Bool = false,
        errorObject: E.Type,
        userToken: String? = nil
    ) async throws -> T {
        let url = try endpoint.urlWithPath()
        let headers = authorizedHeaders(endpointHeaders: endpoint.headers(userToken: userToken))
        
        return try await performRequest(
            url: url,
            method: method,
            headers: headers,
            body: body,
            sensitiveRequestBodyData: sensitiveRequestBodyData,
            errorObject: errorObject
        )
    }
    
    private func authorizedHeaders(endpointHeaders: [String: String]? = nil) -> [String: String] {
        var finalHeaders = endpointHeaders ?? [:]
        [APIHeader.authorizationHeader, APIHeader.apiKeyHeader].forEach {
            finalHeaders.merge($0) { (_, new) in new }
        }
        return finalHeaders
    }
}

final class Network: BaseClass, Networking, HasLoggers {
    typealias Dependencies = HasUrlSessionWrapper & HasLoggerServicing
    
    private let urlSession: URLSessionWrapping
    let logger: LoggerServicing
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.urlSession = dependencies.urlSession
        self.logger = dependencies.logger
    }
    
    // MARK: - Public Interface
    
    func performRequest<T: Decodable, E: APIResponseErroring>(
        url: URL,
        method: Network.HTTPMethod,
        headers: [String: String]?,
        body: Data?,
        sensitiveRequestBodyData: Bool,
        errorObject: E.Type
    ) async throws -> T {
        let dataResponse = try await fetch(
            url: url,
            method: method,
            headers: headers,
            body: body,
            sensitiveRequestBodyData: sensitiveRequestBodyData,
            errorObject: errorObject
        )
        
        // If API doesn’t return any data or we don’t care about the response data (T is Void)
        if T.self == EmptyResponse.self {
            guard let result = EmptyResponse() as? T else {
                /*
                 THIS ERROR SHOULD NEVER OCCUR
                 -> Void is the same as ()
                 -> This error is here only to avoid force casting () as! T
                 */
                throw BaseError(
                    context: .network,
                    message: "Failed to cast Void to \(T.self) for URL \(url.absoluteString)",
                    code: .networking(.apiDecoding),
                    url: url,
                    logger: logger
                )
            }
            return result
        }
        
        return try processResponse(dataResponse: dataResponse, url: url)
    }
    
    // MARK: - Private Helpers
    
    private func fetch<E: APIResponseErroring>(
        url: URL,
        method: Network.HTTPMethod = .GET,
        headers: [String: String]? = nil,
        body: Data? = nil,
        sensitiveRequestBodyData: Bool = false,
        errorObject: E.Type
    ) async throws -> DataResponse {
        let request = urlRequest(url: url, method: method, headers: headers, body: body)
        let (data, response) = try await urlSession(for: request, sensitiveRequestBodyData: sensitiveRequestBodyData)
        let httpResponse = try validateHttpResponse(response)
        
        let dataResponse = DataResponse(
            statusCode: httpResponse.statusCode,
            request: request,
            response: httpResponse,
            data: data
        )
        
        logResponse(dataResponse, sensitiveRequestBodyData: sensitiveRequestBodyData, url: url)
        try checkForErrorResponse(data: data, response: httpResponse, errorObject: errorObject)
        
        return dataResponse
    }
    
    // MARK: - URL construction and processing
    
    private func urlRequest(
        url: URL,
        method: Network.HTTPMethod,
        headers: [String: String]?,
        body: Data?
    ) -> URLRequest {
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        request.httpMethod = method.rawValue
        request.httpBody = body
        return request
    }
    
    private func urlSession(
        for request: URLRequest,
        sensitiveRequestBodyData: Bool
    ) async throws -> (Data, URLResponse) {
        do {
            return try await urlSession.data(for: request)
        } catch {
            throw processUrlSessionError(error, url: request.url)
        }
    }
    
    // MARK: - Response validation and decoding
    
    private func validateHttpResponse(_ response: URLResponse) throws -> HTTPURLResponse {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw BaseError(
                context: .network,
                message: "Invalid HTTPResponse - \(response.debugDescription)",
                code: .networking(.apiDecoding),
                url: response.url,
                logger: logger
            )
        }
        return httpResponse
    }
    
    private func processResponse<T: Decodable>(dataResponse: DataResponse, url: URL) throws -> T {
        guard let data = dataResponse.data else {
            throw BaseError(
                context: .network,
                message: "Empty response for URL \(url.absoluteString)",
                code: .networking(.apiDecoding),
                url: url,
                logger: logger
            )
        }
        
        // Handle the case where T is `Data` type
        if T.self == Data.self {
            guard let safeCastedData = data as? T else {
                /*
                 AGAIN THIS ERROR SHOULD NEVER OCCUR
                 -> we check T is Data before casting it
                 -> This error is here only to avoid force casting data as! T
                 */
                throw BaseError(
                    context: .network,
                    message: "Failed to cast data as \(T.self) for URL \(url.absoluteString)",
                    code: .networking(.apiDecoding),
                    url: url,
                    logger: logger
                )
            }
            return safeCastedData
        }
        
        return try decode(data: data, for: url)
    }
    
    private func decode<T: Decodable>(data: Data, for url: URL) throws -> T {
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw BaseError(
                context: .network,
                message: "Cannot decode response for URL \(url.absoluteString)",
                code: .general(.jsonDecoding),
                url: url,
                logger: logger
            )
        }
    }
    
    // MARK: - Error handling
    
    private func checkForErrorResponse<E: APIResponseErroring>(
        data: Data,
        response: HTTPURLResponse,
        errorObject: E.Type
    ) throws {
        guard response.isErrorResponse else { return }
        
        if let apiError = try? JSONDecoder().decode(errorObject, from: data) {
            throw BaseError(
                context: .api,
                message: apiError.message,
                code: .genericStatusCode(response.statusCode),
                url: response.url,
                logger: logger
            )
        } else {
            throw BaseError(
                context: .api,
                message: "Unable to decode message from API: \(response.statusCode)",
                code: .networking(.apiDecoding),
                url: response.url,
                logger: logger
            )
        }
    }
    
    private func processUrlSessionError(_ error: Error, url: URL?) -> BaseError {
        var errorMessage = "General"
        var code: ErrorCodes = .networking(.unknown)
        
        if let urlError = error as? URLError {
            errorMessage = urlError.errorMessage
            code = .networking(urlError.errorCode)
        }
        
        return BaseError(
            context: .network,
            message: errorMessage,
            code: code,
            url: url,
            logger: logger
        )
    }
    
    // MARK: - Logging
    
    private func logResponse(_ dataResponse: DataResponse, sensitiveRequestBodyData: Bool, url: URL) {
        logger.log(message: "\(url.absoluteString)\n\(dataResponse.toString(sensitiveData: sensitiveRequestBodyData))")
    }
}

extension Network {
    enum HTTPMethod: String {
        case GET, POST, PUT, DELETE, PATCH
    }
}
