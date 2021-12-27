//
//  AppDelegate.swift
//  kude (iOS)
//
//  Created by Ted Bennett on 27/12/2021.
//

import UIKit
import FirebaseMessaging

// For future use with Apple Music
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        MessagingManager.shared.test()
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) async -> UIBackgroundFetchResult {
        MessagingManager.shared.handleMessage(userInfo)
        return .newData
    }
    
    func requestAppleMusicPermissions() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in }
        
    }
}

