//
//  SceneDelegate.swift
//  BCBF
//
//  Created by user216835 on 4/20/22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        if let urlContext = connectionOptions.urlContexts.first {
            
            print("Launched with url: \(urlContext.url)")
            
            handleURL(urlContext.url)
        }
    }
    
    func handleURL(_ url: URL) {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), let queryItems = urlComponents.queryItems, let action = urlComponents.host, urlComponents.scheme == "bcbf" else {
            print("Invalid URL: \(url)")
            return
        }

        // Turn qury string into a dictionary of strings.
        var parameters: [String: String] = [:]
        queryItems.forEach { queryItem in
            parameters[queryItem.name] = queryItem.value
        }
        
        switch action {
            case "login":
                if let phone = parameters["phone"] {
                    print("Log in with phone \(phone)")
                    
                    // Create instance of Forgotten Password view controller from Storyboard
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let LoginViewController = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
                    
                    LoginViewController.phoneNumber = phone
                    
                    // Push that view controller onto navigation stack, without animating.
                    let navigationController = window?.rootViewController as? UINavigationController
                    navigationController?.pushViewController(LoginViewController, animated: false)
                }
            case "register":
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let RegisterViewController = storyboard.instantiateViewController(withIdentifier: "RegisterVC") as! RegisterViewController
                let navigationController = window?.rootViewController as? UINavigationController
                navigationController?.pushViewController(RegisterViewController, animated: false)
            default:
                print("Unrecognised action passed via URL: \(action).")
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {

        if let urlContext = URLContexts.first {
            
            print("Already running, handle url: \(urlContext.url)")
            
            handleURL(urlContext.url)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

