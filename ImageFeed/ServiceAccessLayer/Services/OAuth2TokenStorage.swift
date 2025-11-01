import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    // MARK: - Properties
    private let userDefaults = UserDefaults.standard
    private let tokenKey = "bearerToken"
    
    static let shared = OAuth2TokenStorage()
    
    var token: String? {
        get {
            // Получаем токен из Keychain
            return KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let token = newValue {
                // Сохраняем токен в Keychain
                KeychainWrapper.standard.set(token, forKey: tokenKey)
            } else {
                // Удаляем токен из Keychain
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
            }
        }
    }
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Public Methods
    func clearToken() {
        token = nil
    }
}
