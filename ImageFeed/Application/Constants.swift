import Foundation

enum Constants {
    static let accessKey  = "wszUig8pYoh4rsY0OONc88yxixfN-aFucjtIYAv3DC0"
    static let secretKey = "MtAh129S_RNuX4wW2cTvAdeQG8NP2zrVi5iMZqARdBo"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL: URL = {
        guard let url =  URL(string: "https://api.unsplash.com") else {
            assertionFailure("Invalid base URL string")
            return URL(fileURLWithPath: "/")
        }
        return url
    }()
}
