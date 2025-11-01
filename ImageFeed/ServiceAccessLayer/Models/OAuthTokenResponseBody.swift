import Foundation

public struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    
    static func decodeTokenResponse(from jsonData: Data) throws -> OAuthTokenResponseBody {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(OAuthTokenResponseBody.self, from: jsonData)
    }
}
