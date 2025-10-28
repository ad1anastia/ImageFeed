import Foundation

extension URLSession {
    /// Выполняет сетевой запрос и возвращает результат в completion.
    /// Выполняется безопасно: все замыкания вызываются на главном потоке.
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        
        let completeOnMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request) { data, response, error in
            // Ошибка сети
            if let error = error {
                completeOnMainThread(.failure(NetworkError.urlRequestError(error)))
                return
            }
            
            // Проверяем ответ сервера
            guard
                let httpResponse = response as? HTTPURLResponse
            else {
                completeOnMainThread(.failure(NetworkError.invalidRequest))
                return
            }
            
            let statusCode = httpResponse.statusCode
            
            // Проверяем статус код
            guard (200..<300).contains(statusCode) else {
                print("⚠️ Server returned HTTP \(statusCode)")
                completeOnMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                return
            }
            
            // Проверяем наличие данных
            guard let data = data else {
                completeOnMainThread(.failure(NetworkError.urlSessionError))
                return
            }
            
            // Всё успешно — возвращаем данные
            completeOnMainThread(.success(data))
        }
        
        return task
    }
}
