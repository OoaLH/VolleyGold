//
//  AppDelegate.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-26.
//

import UIKit
import StoreKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = HomeViewController()
        window?.makeKeyAndVisible()
        
        registerForPushNotifications()
        
        SKPaymentQueue.default().add(PurchaseManager.shared)
        PurchaseManager.shared.updatePurchaseStatus()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        if GameCenterManager.shared.currentMatch != nil {
            pushNotifications(title: "You are in an online match", body: "Don't let your teammate wait. Return to continue.")
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        SKPaymentQueue.default().remove(PurchaseManager.shared)
    }
    
    func registerForPushNotifications() {
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
          print("Notification permission granted: \(granted)")
        }
    }
    
    func pushNotifications(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}

