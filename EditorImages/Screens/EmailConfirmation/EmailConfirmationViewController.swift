//
//  EmailConfirmationViewController.swift
//  EditorImages
//
//  Created by Кирилл Зубков on 14.04.2024.
//

import UIKit
import SnapKit
import Combine

final class EmailConfirmationViewController: UIViewController {
    
    // MARK: - Constants
    
    private enum Constants {
        static let containerHorizontalInsets: CGFloat = 40
        static let containerInnerInsets: CGFloat = 20
        static let containerCornerRadius: CGFloat = 20
        static let maxContainerWidth: CGFloat = 400
    }
    
    
    // MARK: - Properties
    
    private let viewModel = EmailConfirmationViewModel()
    private var subscriptions = Set<AnyCancellable>()
    
    private lazy var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(dimmingViewTapped))
        view.addGestureRecognizer(gesture)
        return view
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = Constants.containerCornerRadius
        return view
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Пожалуйста, перейдите по ссылке, отправленной на E-Mail адрес"
        return label
    }()
    
    
    // MARK: - Init
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addViews()
        addConstraints()
        binding()
    }
    
    
    // MARK: - Private Methods
    
    private func addViews() {
        view.addSubview(dimmingView)
        view.addSubview(containerView)
        containerView.addSubview(textLabel)
    }
    
    private func addConstraints() {
        dimmingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(Constants.maxContainerWidth)
                .priority(.medium)
            make.leading.greaterThanOrEqualToSuperview()
                .offset(Constants.containerHorizontalInsets)
        }
        
        textLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.edges.equalToSuperview().inset(Constants.containerInnerInsets)
        }
    }
    
    private func binding() {
        viewModel.$shouldDismissScreen
            .sink { [weak self] shouldDismiss in
                self?.dismiss(animated: true)
            }
            .store(in: &subscriptions)
    }
    
    
    // MARK: - Actions
    
    @objc
    private func dimmingViewTapped() {
        viewModel.isDimmingViewTapped = true
    }
    
}
