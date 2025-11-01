import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private init() {}
    
    func fetchAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if task != nil {
             if lastCode != code {
                 task?.cancel()
             } else {
                 completion(.failure(OAuth2ServiceError.invalidRequest))
                 return
             }
        } else {
            if lastCode == code {
                completion(.failure(OAuth2ServiceError.invalidRequest))
                return
            }
        }
        lastCode = code
        

        guard let request = makeOAuthTokenRequest(code: code) else {
            DispatchQueue.main.async {
                completion(.failure(OAuth2ServiceError.badUrl))
            }
            lastCode = nil
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            
            defer { // Отложенный вызов. Код в скобках вызовется перед любым return
                self?.task = nil
                self?.lastCode = nil
            }
            
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
                let responseBody = try OAuthTokenResponseBody.decodeTokenResponse(from: data)
                DispatchQueue.main.async {
                    completion(.success(responseBody.accessToken))
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let url = URL(string: "https://unsplash.com/oauth/token") else {
            print("Error: Invalid URL for token: https://unsplash.com/oauth/token")
            return nil
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
        
        return request
    }
}
