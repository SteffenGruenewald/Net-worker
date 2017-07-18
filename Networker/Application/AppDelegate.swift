
//
//  AppDelegate.swift
//  Marketmaker
//
//  Created by Big shark on 11/10/2016.
//  Copyright © 2016 Big shark. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import FirebaseAuth
import CoreLocation
import FBSDKCoreKit
import LinkedinSwift


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,CLLocationManagerDelegate {
    
    var window: UIWindow?
    
    let locationManager = CLLocationManager()
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //facebook login module
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        
        
        
        
        //set firebase messaging
        FirebaseApp.configure()
        
        // [START set_messaging_delegate]
        Messaging.messaging().delegate = self
        // [END set_messaging_delegate]
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        //set base url of firebase
        setBaseUrl()
        
        
        //location manager define
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestLocation()
        updateTimer()
        locationManager.requestLocation()
        
        
        UserDefaults.standard.set(25, forKey: "distance")
        
        
        //set navigation root view controllers
        //setNavigationRoots()
        return true
    }
    
    func setBaseUrl(){
        var myDict: NSDictionary?
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        if let dict = myDict {
            
            
            //let distobject = dict.object(forKey: "informaton Property List") as! [String: String]
            Constants.FIR_STORAGE_BASE_URL = "gs://" + (dict.value(forKey: "STORAGE_BUCKET") as! String)
        }
    }
    
    func updateTimer(){
        
        Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(updateLocation), userInfo: nil, repeats: true)
    }
    
    func updateLocation()
    {
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.first
        
        currentLatitude = (location?.coordinate.latitude)! as Double
        currentLongitude = (location?.coordinate.longitude)! as Double
        if(currentUser.user_id > 0){
            currentUser.user_latitude = currentLatitude
            currentUser.user_longitude = currentLongitude
        }
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
        
    func applicationWillResignActive(_ application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        FBSDKAppEvents.activateApp()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:
        //ApiFunctions.send
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "CloseChatting"), object: nil)
        
    }
    
    
    //when token refreshed, user register it.
    func tokenRefreshNotification(_ notification: Notification) {
        if let refreshedToken = InstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
            
            //UserDefault.setString(value: refreshedToken, key: "token")
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        //connectToFcm()
    }
    
    
    
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // Print message ID.
        
        //if (application.app)
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        // Print full message.{
        NSLog("\(userInfo)")
        guard let rvc = self.window?.rootViewController else{
            return
        }
        let alertObject = userInfo["aps"] as! [String: AnyObject]
        let alertString = alertObject["alert"] as! String
        /*
         if let vc = getCurrentViewController(vc: rvc) {
         let alertView = AlertView()
         alertView.message = alertString
         alertView.showAlertView()
         vc.view.addSubview(alertView)
         
         }*/
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        // Print full message.{
        NSLog("\(userInfo)")
        guard let rvc = self.window?.rootViewController else{
            return
        }
        let alertObject = userInfo["aps"] as! [String: AnyObject]
        let alertString = alertObject["alert"] as! String
        
        // Print full message.
    }
    
    // [END receive_message]
    
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        print("APNs token retrieved: \(deviceToken)")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        var handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        if handled{
            return handled
        }
        //handled =
        
        return true
    }
    
    
}



/// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        // Print full message.
        print("%@", userInfo)
        guard let rvc = self.window?.rootViewController else{
            return
        }
        let alertObject = userInfo["aps"] as! [String: AnyObject]
        let alertString = alertObject["alert"] as! String
        /*
         if let vc = getCurrentViewController(vc: rvc) {
         let alertView = AlertView()
         alertView.message = alertString
         alertView.showAlertView()
         vc.view.addSubview(alertView)
         
         }*/
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        NSLog("==============Succeeded=================")
    }
}


extension AppDelegate : MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
    }
    
    // [START refresh_token]
    
    
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    // [END ios_10_data_message]
    
}
// [END ios_10_message_handling]
