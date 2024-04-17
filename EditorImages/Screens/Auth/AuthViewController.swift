//
//  AuthViewController.swift
//  EditorImages
//
//  Created by Кирилл Зубков on 14.04.2024.
//

import UIKit
import Combine
import SnapKit

final class AuthViewController: UIViewController {
    
    private enum Constants {
        static let buttonTitleSizeOffset: CGFloat = 24
        static let emailPasswordViewTopOffset: CGFloat = 220
        static let emailPasswordViewTrailingLeadingInset: CGFloat = 20
        static let smallOffset: CGFloat = 25
        static let emailPasswordWidth: CGFloat = 400
    }
    
    // MARK: - Properties
    
    private let viewModel = AuthViewModel()
    private var subscriptions = Set<AnyCancellable>()
    
    private let emailPasswordView = EmailPasswordView()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign in", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: Constants.buttonTitleSizeOffset)
        button.setTitleColor(.lightGray, for: .disabled)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self,
                         action: #selector(loginButtonTapped),
                         for: .touchUpInside)
        return button
    }()
    
    private lazy var registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign up", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: Constants.buttonTitleSizeOffset)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self,
                         action: #selector(registerButtonTapped),
                         for: .touchUpInside)
        return button
    }()
    
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        addViews()
        addConstaints()
        binding()
    }
    
    
    // MARK: - Private Methods
    
    private func binding() {
        emailPasswordView.emailTextField.textPublisher
            .assign(to: \.email, on: viewModel)
            .store(in: &subscriptions)
        
        emailPasswordView.passwordTextField.textPublisher
            .assign(to: \.password, on: viewModel)
            .store(in: &subscriptions)
        
        viewModel.$loginButtonIsEnabled
            .sink { [weak self] isEnabled in
                self?.loginButton.isEnabled = isEnabled
            }
            .store(in: &subscriptions)
        
        viewModel.$registrationScreenShouldShow
            .sink { [weak self] shouldShow in
                if shouldShow {
                    self?.viewModel.registrationScreenShouldShow = false
                    self?.showRegistrationScreen()
                }
            }
            .store(in: &subscriptions)
        
        viewModel.$errorTitleMessage
            .sink { [weak self] error in
                if let error {
                    self?.showAlert(title: error.title,
                                    message: error.message)
                    self?.viewModel.errorTitleMessage = nil
                }
            }
            .store(in: &subscriptions)
        
        viewModel.$emailConfirmationShouldShow
            .sink { [weak self] shouldShow in
                if shouldShow {
                    self?.viewModel.emailConfirmationShouldShow = false
                    self?.showEmailConfirmation()
                }
            }
            .store(in: &subscriptions)
    }
    
    private func addViews() {
        view.addSubview(emailPasswordView)
        view.addSubview(loginButton)
        view.addSubview(registerButton)
    }
    
    private func addConstaints() {
        emailPasswordView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(Constants.emailPasswordViewTopOffset)
            make.width.equalTo(Constants.emailPasswordWidth)
                .priority(.medium)
            make.leading.greaterThanOrEqualToSuperview()
                .offset(Constants.emailPasswordViewTrailingLeadingInset)
        }
        
        loginButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(emailPasswordView.snp.bottom)
                .offset(Constants.smallOffset)
        }
        
        registerButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(loginButton.snp.bottom)
                .offset(Constants.smallOffset)
        }
        
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
    private func showRegistrationScreen() {
        let registrationViewController = RegistrationViewController()
        navigationController?.pushViewController(registrationViewController, animated: true)
    }
    
    private func showEmailConfirmation() {
        let emailConfirmationViewController = EmailConfirmationViewController()
        present(emailConfirmationViewController, animated: true)
    }
    
    
    // MARK: - Actions
    
    @objc
    private func loginButtonTapped() {
        viewModel.isLoginButtonTapped = true
    }
    
    @objc
    private func registerButtonTapped() {
        viewModel.isRegisterButtonTapped = true
    }
    
}
