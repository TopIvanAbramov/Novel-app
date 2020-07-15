//
//  AppDelegate.swift
//  Novel
//
//  Created by Иван Абрамов on 11.07.2020.
//  Copyright © 2020 Иван Абрамов. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        
        FirebaseAuth.Auth.auth().addStateDidChangeListener { (auth, user) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
           if user != nil {
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "MainScreenViewController") as? MainScreenViewController
                UIApplication.shared.keyWindow?.rootViewController = initialViewController
           } else {
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "ChooseAuthorizationViewController") as? ChooseAuthorizationViewController
                UIApplication.shared.keyWindow?.rootViewController = initialViewController
            }
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

