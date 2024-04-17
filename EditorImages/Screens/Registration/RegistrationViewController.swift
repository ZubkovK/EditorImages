//
//  RegistrationViewController.swift
//  EditorImages
//
//  Created by Кирилл Зубков on 13.04.2024.
//

import UIKit
import Combine
import SnapKit

final class RegistrationViewController: UIViewController {
    
    private enum Constants {
        static let registerButtonSizeFon: CGFloat = 24
        static let emailViewTopOffset: CGFloat = 220
        static let emailViewLeadingTrailingInset: CGFloat = 20
        static let registrButtonTopOffset: CGFloat = 25
        static let emailPasswordWidth: CGFloat = 400
    }
    
    // MARK: - Properties
    
    private let viewModel = RegistrationViewModel()
    private var subscriptions = Set<AnyCancellable>()
    
    private let emailPasswordView = EmailPasswordView()
    
    private lazy var registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign up", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: Constants.registerButtonSizeFon)
        button.setTitleColor(.lightGray, for: .disabled)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, 
                         action: #selector(registerButtonTapped),
                         for: .touchUpInside)
        return button
    }()
    
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Sign up"
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
        
        viewModel.$registerButtonIsEnabled
            .sink { [weak self] isEnabled in
                self?.registerButton.isEnabled = isEnabled
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
        view.addSubview(registerButton)
    }
    
    private func addConstaints() {
        emailPasswordView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(Constants.emailViewTopOffset)
            make.width.equalTo(Constants.emailPasswordWidth)
                .priority(.medium)
            make.leading.greaterThanOrEqualToSuperview()
                .offset(Constants.emailViewLeadingTrailingInset)
        }
        
        registerButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(emailPasswordView.snp.bottom).offset(Constants.registrButtonTopOffset)
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
    
    private func showEmailConfirmation() {
        let emailConfirmationViewController = EmailConfirmationViewController()
        present(emailConfirmationViewController, animated: true)
    }
    
    
    // MARK: - Actions
    
    @objc
    private func registerButtonTapped() {
        viewModel.isRegisterButtonTapped = true
    }
    
}
