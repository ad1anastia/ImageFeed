import Foundation

enum OAuth2ServiceError: Error {
    case badUrl
    case invalidRequest
    case noData
    case jsonParsingError
}
