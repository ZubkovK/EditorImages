//
//  LoginPasswordView.swift
//  EditorImages
//
//  Created by Кирилл Зубков on 14.04.2024.
//

import UIKit
import SnapKit

final class EmailPasswordView: UIStackView {
    
    // MARK: - Constants
    
    private enum Constants {
        static let fieldsHeight: CGFloat = 60
        static let bottomLineHeight: CGFloat = 1
    }
    
    
    // MARK: - Properties
    
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите E-Mail"
        textField.textContentType = .emailAddress
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        return textField
    }()
    
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите пароль"
        textField.isSecureTextEntry = true
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        return textField
    }()
    
    private let emailBottomLineLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.lightGray.cgColor
        return layer
    }()
    
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        
        axis = .vertical
        
        // Константы
        layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        isLayoutMarginsRelativeArrangement = true
        
        addViews()
        addConstraints()
        addBorder()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        emailBottomLineLayer.frame = CGRect(x: .zero,
                                            y: emailTextField.frame.height - 1,
                                            width: frame.width,
                                            height: Constants.bottomLineHeight)
    }
    
    
    // MARK: - Private Methods
    
    private func addViews() {
        addArrangedSubview(emailTextField)
        addArrangedSubview(passwordTextField)
    }
    
    private func addConstraints() {
        emailTextField.snp.makeConstraints { make in
            make.height.equalTo(Constants.fieldsHeight)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.height.equalTo(Constants.fieldsHeight)
        }
    }
    
    private func addBorder() {
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.cgColor
        // Константы
        layer.cornerRadius = 15
        
        layer.addSublayer(emailBottomLineLayer)
    }
    
}
