//
//  AppDelegate.swift
//  Swifty_Proteins
//
//  Created by Ivan SELETSKYI on 10/25/18.
//  Copyright © 2018 Ivan SELETSKYI. All rights reserved.
//

import UIKit
import LocalAuthentication

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        guard let nc = window?.rootViewController as? UINavigationController else { return }
        nc.popToViewController(nc.viewControllers[0], animated: false)
        nc.viewControllers[0].loadView()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
    

}

