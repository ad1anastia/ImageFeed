import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private init() {}
    
    func fetchAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://unsplash.com/oauth/token") else {
            print("Error: Invalid URL for token: https://unsplash.com/oauth/token")
            DispatchQueue.main.async {
                completion(.failure(OAuth2ServiceError.badUrl))
            }
            return
        }
        
        // Параметры запроса
        let params = [
            "client_id": Constants.accessKey,
            "client_secret": Constants.secretKey,
            "redirect_uri": Constants.redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]
        
        // Формируем тело запроса в формате x-www-form-urlencoded
        let bodyString = params.map { "\($0)=\($1)" }.joined(separator: "&")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyString.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Проверяем, пришла ли ошибка
            if let error = error {
                print("Network error:: $error.localizedDescription)")
                print("Error details: $error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data,
                  let response = response,
                  let httpResponse = response as? HTTPURLResponse else {
                print("Error: Empty data or response")
                DispatchQueue.main.async {
                    completion(.failure(OAuth2ServiceError.noData))
                }
                return
            }
            
            let statusCode = httpResponse.statusCode
            
            guard 200 ..< 300 ~= statusCode else {
                print("Error: No data received")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.httpStatusCode(statusCode)))
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let responseBody = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(responseBody.access_token))
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}

enum OAuth2ServiceError: Error {
    case badUrl
    case noData
    case jsonParsingError
}
