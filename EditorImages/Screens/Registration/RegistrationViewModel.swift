//
//  RegistrationViewModel.swift
//  EditorImages
//
//  Created by Кирилл Зубков on 13.04.2024.
//

import Combine
import Foundation

final class RegistrationViewModel: ObservableObject {
    
    // MARK: - Input
    
    @Published var email = ""
    @Published var password = ""
    @Published var isRegisterButtonTapped = false
    
    
    // MARK: - Output
    
    @Published var registerButtonIsEnabled = false
    @Published var errorTitleMessage: (title: String, message: String)?
    @Published var passwordNotValidAlertShouldShow = false
    @Published var emailConfirmationShouldShow = false
    
    
    // MARK: - Properties
    
    private var subscriptions = Set<AnyCancellable>()
    
    
    // MARK: - Init
    
    init() {
        binding()
    }
    
    
    // MARK: - Private Methods
    
    private func binding() {
        $email
            .sink { [weak self] newText in
                self?.updateLoginButtonAvailability()
            }
            .store(in: &subscriptions)
        
        $password
            .sink { [weak self] newText in
                self?.updateLoginButtonAvailability()
            }
            .store(in: &subscriptions)
        
        $isRegisterButtonTapped
            .sink { [weak self] isTapped in
                guard let self, isTapped else { return }
                self.isRegisterButtonTapped = false
                
                if validateFields() {
                    AuthService.register(email: email,
                                         password: password) { [weak self] result in
                        switch result {
                        case .success:
                            self?.emailConfirmationShouldShow = true
                        case .failure(let error):
                            self?.errorTitleMessage = (title: error.userTitle,
                                                       message: error.userMessage)
                        }
                    }
                }
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
        registerButtonIsEnabled = !password.isEmpty && !email.isEmpty
    }
    
}
