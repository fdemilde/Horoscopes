//
//  AppDelegate.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/3/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var mobilePlatform = MobilePlatform()
    var userSettings = UserSettings()
    var horoscopesManager = HoroscopesManager()
    var socialManager = SocialManager()
    var locationManager = LocationManager()
    var dataStore = DataStore.sharedInstance
    var currentUser : UserProfile!
    var userLocation : CLLocation!
    var router : Router!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        // hide status bar
        UIApplication.sharedApplication().statusBarHidden = true
        self.setupGAITracker()
        registerForRemoteNotification()
        horoscopesManager.getHoroscopesSigns() // setup Horo array
        currentUser = NSKeyedUnarchiver.unarchiveObjectWithFile(UserProfile.filePath) as? UserProfile ?? UserProfile()
        router = mobilePlatform.router
        self.setupRouter()
        if isFirstTimeUsing() {
            self.showLoginVC()
        }
        
        if(socialManager.isLoggedInZwigglers()){
            locationManager.setupLocationService()
        }
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func showLoginVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier("LoginVC") as! LoginVC
        
        var formSheet = MZFormSheetController(viewController: viewController)
        formSheet.transitionStyle = MZFormSheetTransitionStyle.Fade;
        formSheet.cornerRadius = 0.0;
        formSheet.portraitTopInset = 0.0;
        formSheet.presentedFormSheetSize = CGSizeMake(self.window!.frame.size.width, self.window!.frame.size.height);
        let tabBarVC = self.window?.rootViewController as! UITabBarController
        self.window?.rootViewController?.mz_presentFormSheetController(formSheet, animated: false, completionHandler: nil)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    // ---------------------------------------------
    // MARK: Event tracker Helper
    // ---------------------------------------------
    
    func setupGAITracker(){
        GAI.sharedInstance().trackUncaughtExceptions = true
        GAI.sharedInstance().dispatchInterval = 1
        GAI.sharedInstance().logger.logLevel = GAILogLevel.Error;
        GAI.sharedInstance().trackerWithTrackingId(kAnalyticsAccountId)
    }
    
    func sendTrackEventWithActionName(actionName: String, label:String?, value: Int32){
        // if the value < 0, we should override it with appOpenCounter value
        var _value = 0
        
        if (value < 0) {
            _value = Int(XAppDelegate.mobilePlatform.tracker.appOpenCounter);
        }
        
        var udid = XAppDelegate.mobilePlatform.userCred.getUDID()
        var dict = GAIDictionaryBuilder.createEventWithCategory(udid, action: actionName, label: label, value: NSNumber(int: value)).build() as NSDictionary
        
        GAI.sharedInstance().defaultTracker.send(dict as [NSObject : AnyObject])
        
        var priority = 3
        if(label == defaultAppOpenAction) { priority = 1 }
        if(label == defaultNotificationQuestion) { priority = 3 }
        if(label == defaultViewHoroscope) { priority = 4 }
        if(label == defaultViewArchive) { priority = 3 }
        if(label == defaultChangeSetting) { priority = 2 }
        if(label == defaultFacebook) { priority = 2 }
        if(label == defaultNotification) { priority = 4 }
        if(label == defaultRefreshClick) { priority = 3 }
        if(label == defaultIDFAEventKey) { priority = 1 }
        
        if let label = label {
            XAppDelegate.mobilePlatform.tracker .logWithAction(actionName, label: String(format:"Open=%i,Label=%@", value,label), priority: Int32(priority))
        } else {
            XAppDelegate.mobilePlatform.tracker .logWithAction(actionName, label: String(format:"Open=%i,Label=%@", value,""), priority: Int32(priority))
        }
    }
    
    // MARK: Helpers
    func isFirstTimeUsing() -> Bool{
        if(userSettings.horoscopeSign == -1){
            return true
        } else { return false }
        
    }
    
    func registerForRemoteNotification(){
        var systemVersion = (UIDevice.currentDevice().systemVersion as NSString).floatValue
        if(systemVersion >= 8.0){
            
            var types = UIUserNotificationType.Sound | UIUserNotificationType.Badge | UIUserNotificationType.Alert
            var notifSettings = UIUserNotificationSettings(forTypes: types, categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(notifSettings)
        } else {
            var types = UIRemoteNotificationType.Sound | UIRemoteNotificationType.Badge | UIRemoteNotificationType.Alert
            UIApplication.sharedApplication().registerForRemoteNotificationTypes(types)
        }
    }
    
    // Test function with hardcoded location
    func sendLocation(){
        var googleLink = "https://maps.googleapis.com/maps/api/geocode/json?key=AIzaSyD5jrlKA2Sw6qxgtdVlIDsnuEj7AJbpRtk&latlng=10.714407,106.735349"
        
        var operationManager = AFHTTPRequestOperationManager()
        operationManager.GET(googleLink, parameters: nil,
            success: { (operation, responseObject) -> Void in
                
                var responseDict = responseObject as! Dictionary<String, AnyObject>
                var array = responseDict["results"] as! [AnyObject]
                let data = NSJSONSerialization.dataWithJSONObject(array, options: nil, error: nil)
                let string = NSString(data: data!, encoding: NSUTF8StringEncoding)
                XAppDelegate.socialManager.sendUserUpdateLocation(string as? String, completionHandler: { (result, error) -> Void in
                    if(error == nil){
                        var errorCode = result?["error"] as! Int
                        if(errorCode == 0){
                            var profileDict = result?["profile"] as! Dictionary<String,AnyObject>
                            for (uid, profileDetail) in profileDict {
                                var profile = UserProfile(data: profileDetail as! NSDictionary)
                                XAppDelegate.currentUser = profile
                            }
                        } else {
                           println("Error code === \(errorCode)")
                        }
                    } else {
                        println("Error === \(error)")
                    }
                })
            },
            failure: { (operation, error) -> Void in
                println("sendRequestUpdateUser Error \(error)")
                
        })
    }
    
    func finishedGettingLocation(location : CLLocation){
        // only update once
        if(userLocation == nil){
            userLocation = location
            var googleLink = String(format:"%@%f,%f",GOOGLE_LOCATION_API,location.coordinate.latitude,location.coordinate.longitude)
//            println("finishedGettingLocation  === \(googleLink)")
            
            var operationManager = AFHTTPRequestOperationManager()
            operationManager.GET(googleLink, parameters: nil,
                success: { (operation, responseObject) -> Void in
                    
                    var responseDict = responseObject as! Dictionary<String, AnyObject>
//                    var array = responseDict["results"] as! [AnyObject]
                    let data = NSJSONSerialization.dataWithJSONObject(responseDict, options: nil, error: nil)
                    let string = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    XAppDelegate.socialManager.sendUserUpdateLocation(string as? String, completionHandler: { (result, error) -> Void in
                        if(error == nil){
                            var errorCode = result?["error"] as! Int
                            if(errorCode == 0){
                                var profileDict = result?["profile"] as! Dictionary<String,AnyObject>
                                for (uid, profileDetail) in profileDict {
                                    var profile = UserProfile(data: profileDetail as! NSDictionary)
                                    XAppDelegate.currentUser = profile
                                }
                            } else {
                                println("Error code === \(errorCode)")
                            }
                        } else {
                            println("Error === \(error)")
                        }
                    })
                },
                failure: { (operation, error) -> Void in
                    println("sendRequestUpdateUser Error \(error)")
                    
            })
        }
    }
    
    // MARK: Notification handler
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        var deviceTokenString = String(format:"%@",deviceToken)
        XAppDelegate.socialManager.registerAPNSNotificationToken(deviceTokenString, completionHandler: { (response, error) -> Void in
            
        })
        XAppDelegate.socialManager.registerServerNotificationToken(deviceTokenString)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        
    }
    
    // ios 8
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        
    }
    
    // MARK: Router handler
    
    func setupRouter(){
        router.addRoute("/today/:id/:post_id/*info", blockCode: { (param) -> Void in
            println("Route == today param dict = \(param)")
        })
        
        router.addRoute("/today/fortunecookie", blockCode: { (param) -> Void in
            println("Route == fortunecookie param dict = \(param)")
        })
        
        router.addRoute("/archive", blockCode: { (param) -> Void in
            println("Route == archive param dict = \(param)")
        })
        
        router.addRoute("/archive/:date/:sign", blockCode: { (param) -> Void in
            println("Route == archive param dict = \(param)")
        })
        
        router.addRoute("/feed/global", blockCode: { (param) -> Void in
            println("Route == global param dict = \(param)")
        })
        
        router.addRoute("/feed/following", blockCode: { (param) -> Void in
            println("Route == feed following param dict = \(param)")
        })
        
        router.addRoute("/profile/:uid/feed", blockCode: { (param) -> Void in
            println("Route == feed param dict = \(param)")
        })
        
        router.addRoute("/profile/:uid/followers", blockCode: { (param) -> Void in
            println("Route == followers param dict = \(param)")
        })
        
        router.addRoute("/profile/:uid/following", blockCode: { (param) -> Void in
            println("Route == following param dict = \(param)")
        })
        
        router.addRoute("/profile/me", blockCode: { (param) -> Void in
            println("Route == profile me param dict = \(param)")
        })
        
        router.addRoute("/profile/me/setsign", blockCode: { (param) -> Void in
            println("Route == profile me setsign param dict = \(param)")
        })
        
        router.addRoute("/profile/me/findfriends", blockCode: { (param) -> Void in
            println("Route == profile findfriends param dict = \(param)")
        })
        
        router.addRoute("/post/:post_id", blockCode: { (param) -> Void in
            println("Route == post with param dict = \(param)")
        })
        
        router.addRoute("/post/:post_id/hearts", blockCode: { (param) -> Void in
            println("Route == post hearts param dict = \(param)")
        })
        
        router.addRoute("/settings", blockCode: { (param) -> Void in
            println("Route == settings with param dict = \(param)")
        })
    }
}

