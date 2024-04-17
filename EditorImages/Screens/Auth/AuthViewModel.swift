//
//  AuthViewModel.swift
//  EditorImages
//
//  Created by Кирилл Зубков on 14.04.2024.
//

import Combine
import Foundation

final class AuthViewModel: ObservableObject {
    
    // MARK: - Input
    
    @Published var email = ""
    @Published var password = ""
    @Published var isRegisterButtonTapped = false
    @Published var isLoginButtonTapped = false
    
    
    // MARK: - Output
    
    @Published var loginButtonIsEnabled = false
    @Published var registrationScreenShouldShow = false
    @Published var emailConfirmationShouldShow = false
    @Published var errorTitleMessage: (title: String, message: String)?
    
    
    // MARK: - Properties
    
    private var subscriptions = Set<AnyCancellable>()
    
    
    // MARK: - Init
    
    init() {
        binding()
    }
    
    
    // MARK: - Private Methods
    
    private func binding() {
        $email
            .receive(on: RunLoop.main)
            .sink { [weak self] newText in
                self?.updateLoginButtonAvailability()
            }
            .store(in: &subscriptions)
        
        $password
            .receive(on: RunLoop.main)
            .sink { [weak self] newText in
                self?.updateLoginButtonAvailability()
            }
            .store(in: &subscriptions)
        
        $isLoginButtonTapped
            .sink { [weak self] isTapped in
                guard let self, isTapped else { return }
                isLoginButtonTapped = false
                
                if validateFields() {
                    AuthService.login(email: email,
                                      password: password) { [weak self] result in
                        switch result {
                        case .success:
                            if let user = AuthService.currentUser,
                               user.isEmailVerified {
                                ApplicationRouter.shared.open(module: .imageEditor)
                            } else {
                                self?.emailConfirmationShouldShow = true
                            }
                        case .failure(let error):
                            self?.errorTitleMessage = (title: error.userTitle,
                                                       message: error.userMessage)
                        }
                    }
                }
            }
            .store(in: &subscriptions)
        
        $isRegisterButtonTapped
            .sink { [weak self] isTapped in
                guard let self, isTapped else { return }
                isLoginButtonTapped = false
                self.registrationScreenShouldShow = true
            }
            .store(in: &subscriptions)
    }
    
    private func validateFields() -> Bool {
        if !FieldsValidator.isValidEmail(email) {
            errorTitleMessage = (title: "E-Mail адрес не прошел валидацию",
                                 message: "Пожалуйста, введите E-Mail адрес")
            return false
        } else if !FieldsValidator.isValidPassword(password) {
            errorTitleMessage = (title: "Пароль не прошел валидацию",
                                 message: "Пароль должен быть не менее 6 символов")
            return false
        } else {
            return true
        }
    }
    
    private func updateLoginButtonAvailability() {
        loginButtonIsEnabled = !password.isEmpty && !email.isEmpty
    }
    
}
