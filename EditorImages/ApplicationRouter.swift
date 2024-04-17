//
//  ApplicationRouter.swift
//  EditorImages
//
//  Created by Кирилл Зубков on 14.04.2024.
//

import UIKit

enum Module {
    case auth
    case imageEditor
    
    var viewController: UIViewController {
        switch self {
        case .auth:
            return AuthViewController()
        case .imageEditor:
            return ImageEditorViewController()
        }
    }
}

final class ApplicationRouter {
    
    static let shared = ApplicationRouter()
    
    var window: UIWindow?
    
    func open(module: Module) {
        let navigationController = UINavigationController(rootViewController: module.viewController)
        window?.rootViewController = navigationController
    }
    
}
