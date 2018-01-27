//
//  AppDelegate.swift
//  LectureBuddy
//
//  Created by Arthur De Araujo on 11/4/17.
//  Copyright © 2017 Arthur De Araujo. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Firebase
import FirebaseMessaging
import UserNotifications
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        Fabric.with([Crashlytics.self, Answers.self])
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        FirebaseApp.configure()
        firebaseRegisterRemoteNotifications(application: application)
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled:Bool = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        return handled
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let token = Messaging.messaging().fcmToken
        print("FCM token: \(token ?? "")")
    }
    
    // MARK: - Firebase Notifications
    func firebaseRegisterRemoteNotifications(application: UIApplication){
        if #available(iOS 10.0, *) {
            let authOptions : UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_,_ in })
            
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            // For iOS 10 data message (sent via FCM)
            Messaging.messaging().delegate = self
        }
        
        application.registerForRemoteNotifications()
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        var token = Messaging.messaging().fcmToken
        print("FCM token: \(token ?? "")")
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
        // https://firebase.google.com/docs/cloud-messaging/ios/client#register_for_remote_notifications
    }

}

