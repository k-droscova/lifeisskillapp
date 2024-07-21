//
//  Network.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.07.2024.
//

import Foundation

public protocol HasNetwork {
    var network: Networking { get }
}

/// Defines a protocol for core methods for performing network operations.
public protocol Networking {
    /// Performs a network request without returning any data.
    ///
    /// - Parameters:
    ///   - url: The target URL for the request.
    ///   - method: The HTTP method to use (e.g., GET, POST, DELETE).
    ///   - headers: Optional HTTP headers to include in the request.
    ///   - body: Optional HTTP body data to include in the request.
    ///   - sensitiveRequestBodyData: A boolean indicating whether the request body contains sensitive data that should not be logged or exposed in error reports.
    ///   - errorObject: The type of error object expected in case of an API response error.
    /// - Throws: An error if the request fails.
    func _performRequest<E: APIResponseErroring>(
        url: URL,
        method: Network.HTTPMethod,
        headers: [String: String]?,
        body: Data?,
        sensitiveRequestBodyData: Bool,
        errorObject: E.Type
    ) async throws
    
    /// Performs a network request and decodes the response data into a specified type `T` that conforms to the `Decodable` protocol.
    ///
    /// - Parameters:
    ///   - url: The target URL for the request.
    ///   - method: The HTTP method to use.
    ///   - headers: Optional HTTP headers to include in the request.
    ///   - body: Optional HTTP body data to include in the request.
    ///   - sensitiveRequestBodyData: A boolean indicating whether the request body contains sensitive data.
    ///   - errorObject: The type of error object expected in case of an API response error.
    /// - Returns: The decoded response data of type `T`.
    /// - Throws: An error if the request fails or the response data cannot be decoded into the specified type `T`.
    func _performRequestWithDataDecoding<T: Decodable, E: APIResponseErroring>(
        url: URL,
        method: Network.HTTPMethod,
        headers: [String: String]?,
        body: Data?,
        sensitiveRequestBodyData: Bool,
        errorObject: E.Type
    ) async throws -> T
    
    /// Performs a network request and returns the raw response data as `Data`.
    ///
    /// - Parameters:
    ///   - url: The target URL for the request.
    ///   - method: The HTTP method to use.
    ///   - headers: Optional HTTP headers to include in the request.
    ///   - body: Optional HTTP body data to include in the request.
    ///   - sensitiveRequestBodyData: A boolean indicating whether the request body contains sensitive data.
    ///   - errorObject: The type of error object expected in case of an API response error.
    /// - Returns: The raw response data.
    /// - Throws: An error if the request fails.
    func _performRequestWithoutDataDecoding<E: APIResponseErroring>(
        url: URL,
        method: Network.HTTPMethod,
        headers: [String: String]?,
        body: Data?,
        sensitiveRequestBodyData: Bool,
        errorObject: E.Type
    ) async throws -> Data
}

/// Extension for the Networking protocol providing convenient public interface for callers.
///
/// This extension offers convenient methods for performing network requests with simplified signatures.
/// These methods wrap around the core protocol methods and provide default parameter values.
public extension Networking {
    /// Performs a network request to the given URL with the provided data. No data are returned.
    ///
    /// - Parameters:
    ///   - url: The target URL for the request.
    ///   - method: The HTTP method to use (default is `.GET`).
    ///   - headers: Optional HTTP headers to include in the request (default is `nil`).
    ///   - body: Optional HTTP body data to include in the request (default is `nil`).
    ///   - sensitiveRequestBodyData: A boolean indicating whether the request body contains sensitive data that should not be logged or exposed in error reports.
    ///   - errorObject: The type of error object expected in case of an API response error.
    /// - Throws: An error if the request fails.
    func performRequest<E: APIResponseErroring>(
        url: URL,
        method: Network.HTTPMethod = .GET,
        headers: [String: String]? = nil,
        body: Data? = nil,
        sensitiveRequestBodyData: Bool = false,
        errorObject: E.Type
    ) async throws {
        try await _performRequest(
            url: url,
            method: method,
            headers: headers,
            body: body,
            sensitiveRequestBodyData: sensitiveRequestBodyData,
            errorObject: errorObject
        )
    }
    
    /// Performs a network request to the given URL with the provided data and decodes the response data into a specified type `T`.
    ///
    /// - Parameters:
    ///   - url: The target URL for the request.
    ///   - method: The HTTP method to use (default is `.GET`).
    ///   - headers: Optional HTTP headers to include in the request (default is `nil`).
    ///   - body: Optional HTTP body data to include in the request (default is `nil`).
    ///   - sensitiveRequestBodyData: A boolean indicating whether the request body contains sensitive data.
    ///   - sensitiveResponseData: A boolean indicating whether the response body contains sensitive data.
    ///   - errorObject: The type of error object expected in case of an API response error.
    /// - Returns: The decoded response data of type `T`.
    /// - Throws: An error if the request fails or the response data cannot be decoded into the specified type `T`.
    func performRequestWithDataDecoding<T: Decodable, E: APIResponseErroring>(
        url: URL,
        method: Network.HTTPMethod = .GET,
        headers: [String: String]? = nil,
        body: Data? = nil,
        sensitiveRequestBodyData: Bool = false,
        errorObject: E.Type
    ) async throws -> T {
        try await _performRequestWithDataDecoding(
            url: url,
            method: method,
            headers: headers,
            body: body,
            sensitiveRequestBodyData: sensitiveRequestBodyData,
            errorObject: errorObject
        )
    }
    
    /// Performs a network request to the given URL with the provided data and returns the raw response data.
    ///
    /// - Parameters:
    ///   - url: The target URL for the request.
    ///   - method: The HTTP method to use.
    ///   - headers: Optional HTTP headers to include in the request (default is `nil`).
    ///   - body: Optional HTTP body data to include in the request (default is `nil`).
    ///   - sensitiveRequestBodyData: A boolean indicating whether the request body contains sensitive data.
    ///   - sensitiveResponseData: A boolean indicating whether the response body contains sensitive data.
    ///   - errorObject: The type of error object expected in case of an API response error.
    /// - Returns: The raw response data.
    /// - Throws: An error if the request fails.
    func performRequestWithoutDataDecoding<E: APIResponseErroring>(
        url: URL,
        method: Network.HTTPMethod,
        headers: [String: String]? = nil,
        body: Data? = nil,
        sensitiveRequestBodyData: Bool = false,
        errorObject: E.Type
    ) async throws -> Data {
        try await _performRequestWithoutDataDecoding(
            url: url,
            method: method,
            headers: headers,
            body: body,
            sensitiveRequestBodyData: sensitiveRequestBodyData,
            errorObject: errorObject
        )
    }
}


public final class Network: Networking {
    typealias Dependencies = HasUrlSessionWrapper & HasLoggerServicing
    
    /// Helper method to create authorization header.
    public static func authorizationHeader(token: String) -> (key: String, val: String) {
        ("Authorization", "Bearer \(token)")
    }
    
    /// Helper method to create authorization header.
    public static func apiKeyHeader(apiKey: String) -> (key: String, val: String) {
        ("Api-Key", "\(apiKey)")
    }
    /// Helper method to create authorization header.
    public static func apiTokenHeader(token: String) -> (key: String, val: String) {
        ("User-Token", "\(token)")
    }
    
    private var urlSession: URLSessionWrapping
    private var loggerService: LoggerServicing
    
    // MARK: - Initialization
    
    /// Initializes the Network class with its dependencies.
    init(dependencies: Dependencies) {
        self.urlSession = dependencies.urlSession
        self.loggerService = dependencies.logger
    }
    
    // MARK: - Public Interface
    
    /// Performs a request without returning any data.
    public func _performRequest<E: APIResponseErroring>(
        url: URL,
        method: Network.HTTPMethod,
        headers: [String: String]?,
        body: Data?,
        sensitiveRequestBodyData: Bool,
        errorObject: E.Type
    ) async throws {
        _ = try await fetch(
            url: url,
            method: method,
            headers: headers,
            body: body,
            sensitiveRequestBodyData: sensitiveRequestBodyData,
            errorObject: errorObject
        )
        return
    }
    /// Performs a request and decodes the response into the specified type.
    public func _performRequestWithDataDecoding<T: Decodable, E: APIResponseErroring>(
        url: URL,
        method: Network.HTTPMethod,
        headers: [String : String]?,
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
        
        if let data = dataResponse.data {
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw BaseError(
                    context: .network,
                    message: "NetworkError: Cannot decode response - " + url.absoluteString,
                    code: .networking(.apiDecoding),
                    url: url,
                    meta: dataResponse.description(sensitiveData: sensitiveRequestBodyData),
                    logger: loggerService
                )
            }
        } else {
            throw BaseError(
                context: .network,
                message: "NetworkError: Empty response - " + url.absoluteString,
                code: .networking(.apiDecoding),
                url: url,
                meta: dataResponse.description(sensitiveData: sensitiveRequestBodyData),
                logger: loggerService
            )
        }
        
    }
    
    /// Performs a request and returns the response data without decoding it.
    public func _performRequestWithoutDataDecoding<E: APIResponseErroring>(
        url: URL,
        method: Network.HTTPMethod,
        headers: [String: String]?,
        body: Data?,
        sensitiveRequestBodyData: Bool,
        errorObject: E.Type
    ) async throws -> Data {
        let dataResponse = try await fetch(
            url: url,
            method: method,
            headers: headers,
            body: body,
            sensitiveRequestBodyData: sensitiveRequestBodyData,
            errorObject: errorObject
        )
        
        if let data = dataResponse.data {
            return data
        } else {
            throw BaseError(
                context: .network,
                message: "NetworkError: Empty response - " + url.absoluteString,
                code: .networking(.apiDecoding),
                url: url,
                meta: dataResponse.description(sensitiveData: sensitiveRequestBodyData),
                logger: loggerService
            )
        }
        
    }
}

extension Network {
    /// The core method to perform the network request.
    /// - Parameters:
    ///   - url: The target URL for the request.
    ///   - method: HTTP method (default is GET).
    ///   - headers: Optional HTTP headers.
    ///   - body: Optional HTTP body.
    ///   - sensitiveRequestBodyData: Indicates if the request body contains sensitive data.
    ///   - sensitiveResponseData: Indicates if the response body contains sensitive data.
    ///   - errorObject: Type of error object conforming to `ResponseError`.
    /// - Returns: A `DataResponse` containing the status code, request, response, and data.
    /// - Throws: `BaseError` if the request fails or the response contains an error.
    func fetch<E: APIResponseErroring>(
        url: URL,
        method: Network.HTTPMethod = .GET,
        headers: [String: String]? = nil,
        body: Data? = nil,
        sensitiveRequestBodyData: Bool = false,
        errorObject: E.Type
    ) async throws -> DataResponse {
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        request.httpMethod = method.rawValue
        request.httpBody = body
        
        let (data, response) = try await urlSession(
            for: request,
            sensitiveRequestBodyData: sensitiveRequestBodyData
        )
        
        guard let httpResponse = response as? HTTPURLResponse else {
            let errorMessage = "NetworkError: Invalid HTTPResponse - " + url.absoluteString
            throw BaseError(
                context: .network,
                message: errorMessage,
                code: .networking(.apiDecoding),
                url: url,
                logger: loggerService
            )
        }
        
        let dataResponse = DataResponse(
            statusCode: httpResponse.statusCode,
            request: request,
            response: httpResponse,
            data: data
        )
        
        // Do not share sensitive data like login credentials!
        loggerService.log(message:
                            ""
                          + url.absoluteString + "\n"
                          + dataResponse.toString(sensitiveData: sensitiveRequestBodyData)
                          
        )
        
        let statusResponseType = httpResponse.status?.responseType
        let statusCode = httpResponse.statusCode
        if statusResponseType == .clientError || statusResponseType == .serverError {
            do {
                let apiError = try JSONDecoder().decode(errorObject, from: data)
                throw BaseError(
                    context: .api,
                    message: apiError.message,
                    code: .statusCode(statusCode),
                    url: url,
                    meta: dataResponse.description(sensitiveData: sensitiveRequestBodyData),
                    logger: loggerService)
            } catch let error {
                if error is DecodingError {
                    throw BaseError(
                        context: .api,
                        message: "Unable to decode message for API Error \(statusCode)",
                        code: .general(.jsonDecoding),
                        url: url,
                        meta: dataResponse.description(sensitiveData: sensitiveRequestBodyData),
                        logger: loggerService
                    )
                } else {
                    throw error
                }
            }
        }
        
        return dataResponse
    }
    
    /// Performs the network request using `URLSession`.
    /// - Parameters:
    ///   - request: The `URLRequest` to be executed.
    ///   - sensitiveRequestBodyData: Indicates if the request body contains sensitive data.
    /// - Returns: A tuple containing the response data and URL response.
    /// - Throws: `BaseError` if the request fails or if there is an error in the response.
    func urlSession(
        for request: URLRequest,
        sensitiveRequestBodyData: Bool
    ) async throws -> (Data, URLResponse) {
        do {
            return try await urlSession.data(for: request)
        } catch {
            let urlString = request.url?.absoluteString ?? ""
            var errorMessage = "General"
            var code: ErrorCodes = .networking(.unknownNetworkError)
            
            // URL loading system error codes
            // https://developer.apple.com/documentation/foundation/1508628-url_loading_system_error_codes
            if let urlError = error as? URLError {
                // Error codes representing unavailable internet connection
                let noConnectionCodes = [
                    URLError.notConnectedToInternet,
                    .dataNotAllowed, // when user has cell data disabled we get this error
                    .networkConnectionLost
                ]
                // Error codes representing invalid URL
                let invalidURLCodes = [
                    URLError.badURL,
                    .unsupportedURL,
                    .cannotFindHost
                ]
                
                if noConnectionCodes.contains(urlError.code) {
                    errorMessage = "NoConnection"
                    code = .networking(.noConnection)
                } else if invalidURLCodes.contains(urlError.code) {
                    errorMessage = "InvalidURL"
                    code = .networking(.invalidURL)
                } else if urlError.code == .timedOut {
                    errorMessage = "TimeOut"
                    code = .networking(.timeout)
                }
            }
            
            throw BaseError(
                context: .network,
                message: "NetworkError: " + errorMessage + " - " + urlString,
                code: code,
                url: request.url,
                meta: request.description(sensitiveData: sensitiveRequestBodyData),
                logger: loggerService
            )
        }
    }
}

public extension Network {
    enum HTTPMethod: String {
        case GET, POST, PUT, DELETE, PATCH
    }
}
