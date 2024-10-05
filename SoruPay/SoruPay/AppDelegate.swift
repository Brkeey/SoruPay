//
//  AppDelegate.swift
//  SoruPay
//
//  Created by Berke  on 1.10.2024.
//

// AppDelegate.swift oluşturun
import UIKit
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        NotificationsManager.shared.requestAuthorization()
        application.registerForRemoteNotifications()
        return true
    }

    // Push Notification için gerekli delegate metodları
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}

