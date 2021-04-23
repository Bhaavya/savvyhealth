//
//  SceneDelegate.swift
//  Savvy
//
//  Created by Bhavya on 6/18/20.
//  Copyright © 2020 uiuc. All rights reserved.
//

import Foundation
import UIKit
@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window
        print("Scene")

            let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewcontroller:UIViewController = mainstoryboard.instantiateViewController(withIdentifier: "login") as! UIViewController
            window.rootViewController = newViewcontroller
            window.makeKeyAndVisible()
        }
    }

@available(iOS 13.0, *)
func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
    }

@available(iOS 13.0, *)
func sceneDidBecomeActive(_ scene: UIScene) {
        // Not called under iOS 12 - See AppDelegate applicationDidBecomeActive
    }

@available(iOS 13.0, *)
func sceneWillResignActive(_ scene: UIScene) {
        // Not called under iOS 12 - See AppDelegate applicationWillResignActive
    }

@available(iOS 13.0, *)
func sceneWillEnterForeground(_ scene: UIScene) {
        // Not called under iOS 12 - See AppDelegate applicationWillEnterForeground
    }

@available(iOS 13.0, *)
func sceneDidEnterBackground(_ scene: UIScene) {
        // Not called under iOS 12 - See AppDelegate applicationDidEnterBackground
    
}
