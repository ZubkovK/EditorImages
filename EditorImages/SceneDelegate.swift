//
//  SceneDelegate.swift
//  EditorImages
//
//  Created by Кирилл Зубков on 13.04.2024.
//

import UIKit
import FirebaseDynamicLinks

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow? {
        get {
            return ApplicationRouter.shared.window
        }
        set {
            
        }
    }

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        window.makeKeyAndVisible()
        ApplicationRouter.shared.window = window
        
        if let user = AuthService.currentUser {
            if user.isEmailVerified {
                ApplicationRouter.shared.open(module: .imageEditor)
            } else {
                AuthService.logout()
                ApplicationRouter.shared.open(module: .auth)
            }
        } else {
            ApplicationRouter.shared.open(module: .auth)
        }
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard let url = userActivity.webpageURL else { return }
        DynamicLinks.dynamicLinks().handleUniversalLink(url) { link, _ in
            if let url = link?.url, url.absoluteString.contains("verifyeeditorimages.page.link") {
                NotificationCenter.default.post(name: .emailVerified, object: nil)
            }
        }
    }

}

