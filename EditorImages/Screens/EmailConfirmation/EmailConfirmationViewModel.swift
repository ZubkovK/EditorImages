//
//  EmailConfirmationViewModel.swift
//  EditorImages
//
//  Created by Кирилл Зубков on 14.04.2024.
//

import Combine
import Foundation

final class EmailConfirmationViewModel: ObservableObject {
    
    // MARK: - Input
    
    @Published var isDimmingViewTapped = false
    
    
    // MARK: - Output
    
    @Published var shouldDismissScreen = false
    
    
    // MARK: - Properties
    
    private var subscriptions = Set<AnyCancellable>()
    
    
    // MARK: - Init
    
    init() {
        binding()
        
        if let user = AuthService.currentUser {
            AuthService.sendConfirmationLetter(to: user) { _ in }
        }
    }
    
    
    // MARK: - Private Methods
    
    private func binding() {
        $isDimmingViewTapped
            .sink { [weak self] isTapped in
                if isTapped {
                    self?.isDimmingViewTapped = false
                    AuthService.logout()
                    self?.shouldDismissScreen = true
                }
            }
            .store(in: &subscriptions)
        
        NotificationCenter.default.addObserver(forName: .emailVerified,
                                               object: nil,
                                               queue: .main) { _ in
            if let user = AuthService.currentUser {
                user.reload { _ in
                    if user.isEmailVerified {
                        ApplicationRouter.shared.open(module: .imageEditor)
                    }
                }
            }
        }
    }
    
}
