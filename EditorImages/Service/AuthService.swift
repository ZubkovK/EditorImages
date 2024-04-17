//
//  AuthService.swift
//  EditorImages
//
//  Created by Кирилл Зубков on 14.04.2024.
//

import FirebaseAuth

enum AuthServiceError: Error {
    case emailAlreadyInUse
    case errorInvalidCredential
    case otherError(String)
    
    var userTitle: String {
        switch self {
        case .emailAlreadyInUse:
            return "Пользователь с таким E-Mail уже существует"
        case .errorInvalidCredential, 
                .otherError:
            return "Ошибка"
        }
    }
    
    var userMessage: String {
        switch self {
        case .emailAlreadyInUse:
            return "Попробуйте другой E-Mail адрес"
        case .errorInvalidCredential:
            return "Пользователя с такими E-Mail и паролем не существует"
        case .otherError(let string):
            return string
        }
    }
}

final class AuthService {
    
    private enum Constants {
        static let errorKey = "FIRAuthErrorUserInfoNameKey"
        static let emailAlreadyInUse = "ERROR_EMAIL_ALREADY_IN_USE"
        static let invalidCredential = "ERROR_INVALID_CREDENTIAL"
    }
    
    static var currentUser: User? {
        return Auth.auth().currentUser
    }
    
    private init() { }
    
    static func login(email: String,
                      password: String,
                      completion: @escaping (Result<AuthDataResult, AuthServiceError>) -> Void) {
        Auth.auth().signIn(withEmail: email,
                           password: password) { data, error in
            if let error {
                if (error as NSError).userInfo[Constants.errorKey] as? String == Constants.invalidCredential {
                    completion(.failure(.errorInvalidCredential))
                } else {
                    completion(.failure(.otherError(error.localizedDescription)))
                }
            } else if let data {
                completion(.success(data))
            } else {
                completion(.failure(.otherError("Data not loaded")))
            }
        }
    }
    
    static func logout() {
        try? Auth.auth().signOut()
    }
    
    static func register(email: String,
                         password: String,
                         completion: @escaping (Result<AuthDataResult, AuthServiceError>) -> Void) {
        Auth.auth().createUser(withEmail: email,
                               password: password) { data, error in
            if let error {
                if (error as NSError).userInfo[Constants.errorKey] as? String == Constants.emailAlreadyInUse {
                    completion(.failure(.emailAlreadyInUse))
                } else {
                    completion(.failure(.otherError(error.localizedDescription)))
                }
            } else if let data {
                completion(.success(data))
            } else {
                completion(.failure(.otherError("Data not loaded")))
            }
        }
    }
    
    static func sendConfirmationLetter(to user: User,
                                       completion: @escaping (Result<Void, AuthServiceError>) -> Void) {
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(string: "https://verifyeeditorimages.page.link")
        user.sendEmailVerification(with: actionCodeSettings) { error in
            if let error {
                completion(.failure(.otherError(error.localizedDescription)))
            } else {
                completion(.success(()))
            }
        }
    }
    
}
