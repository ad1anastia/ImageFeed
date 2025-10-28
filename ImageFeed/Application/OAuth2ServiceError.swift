import Foundation

enum OAuth2ServiceError: Error {
    case badUrl
    case noData
    case jsonParsingError
}
