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
    var router : Router!
    var userLocation : CLLocation!
    
    var badge = 0 as Int
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        // hide status bar
        UIApplication.sharedApplication().statusBarHidden = true
        router = XAppDelegate.mobilePlatform.router
        setupRouter()
        self.setupGAITracker()
        horoscopesManager.getHoroscopesSigns() // setup Horo array
        currentUser = NSKeyedUnarchiver.unarchiveObjectWithFile(UserProfile.filePath) as? UserProfile ?? UserProfile()
        
        if(socialManager.isLoggedInZwigglers()){
            // sendLocation() // for testing
            locationManager.setupLocationService()
        }
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
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
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        let route = "/" + url.host! + url.path!
        XAppDelegate.mobilePlatform.router.handleRoute(route)
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
        
        let udid = XAppDelegate.mobilePlatform.userCred.getUDID()
        let dict = GAIDictionaryBuilder.createEventWithCategory(udid, action: actionName, label: label, value: NSNumber(int: Int32(_value))).build() as NSDictionary
        
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
    
    func registerForRemoteNotification(){
        if #available(iOS 8.0, *) {
            let types : UIUserNotificationType = [.Sound, .Badge, .Alert]
            let notifSettings = UIUserNotificationSettings(forTypes: types, categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(notifSettings)
        } else {
            // Fallback on earlier versions
            let types : UIRemoteNotificationType = [.Sound, .Badge, .Alert]
            UIApplication.sharedApplication().registerForRemoteNotificationTypes(types)
        }
    }
    
    // Test function with hardcoded location
    func sendLocation(){
        let googleLink = "https://maps.googleapis.com/maps/api/geocode/json?key=AIzaSyD5jrlKA2Sw6qxgtdVlIDsnuEj7AJbpRtk&latlng=10.714407,106.735349"
        let url = NSURL(string: googleLink)
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithURL(url!, completionHandler: { (data: NSData?, response:NSURLResponse?,
            error: NSError?) -> Void in
            
            if let data = data {
                let string = NSString(data: data, encoding: NSUTF8StringEncoding)
                XAppDelegate.socialManager.sendUserUpdateLocation(string as? String, completionHandler: { (result, error) -> Void in
                    if(error == nil){
                        let errorCode = result?["error"] as! Int
                        if(errorCode == 0){
                            let profileDict = result?["profile"] as! Dictionary<String,AnyObject>
                            for (_, profileDetail) in profileDict {
                                let profile = UserProfile(data: profileDetail as! NSDictionary)
                                XAppDelegate.currentUser = profile
                            }
                        } else {
                            print("Error code === \(errorCode)")
                        }
                    } else {
                        print("Error === \(error)")
                    }
                })

            }
        })
        dataTask.resume()
    }
    
    func finishedGettingLocation(location : CLLocation){
        // only update once
        if(userLocation == nil){
            userLocation = location
            let googleLink = String(format:"%@%f,%f",GOOGLE_LOCATION_API,location.coordinate.latitude,location.coordinate.longitude)
//            println("finishedGettingLocation  === \(googleLink)")
            
            let url = NSURL(string: googleLink)
            let session = NSURLSession.sharedSession()
            let dataTask = session.dataTaskWithURL(url!, completionHandler: { (data: NSData?, response:NSURLResponse?,
                error: NSError?) -> Void in
                
                if let data = data {
                    let string = NSString(data: data, encoding: NSUTF8StringEncoding)
                    XAppDelegate.socialManager.sendUserUpdateLocation(string as? String, completionHandler: { (result, error) -> Void in
                        if(error == nil){
                            let errorCode = result?["error"] as! Int
                            if(errorCode == 0){
                                let profileDict = result?["profile"] as! Dictionary<String,AnyObject>
                                for (_, profileDetail) in profileDict {
                                    let profile = UserProfile(data: profileDetail as! NSDictionary)
                                    XAppDelegate.currentUser = profile
                                }
                            } else {
                                print("Error code === \(errorCode)")
                            }
                        } else {
                            print("Error === \(error)")
                        }
                    })
                    
                }
            })
            dataTask.resume()
        }
    }
    
    // MARK: Notification handler
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let deviceTokenString = String(format:"%@",deviceToken)
//        NSLog("didRegisterForRemoteNotificationsWithDeviceToken = %@", deviceTokenString)
        XAppDelegate.socialManager.registerServerNotificationToken(deviceTokenString)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("didFailToRegisterForRemoteNotificationsWithError didFailToRegisterForRemoteNotificationsWithError")
    }
    
    // ios 8
    
    @available(iOS 8.0, *)
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        if ( application.applicationState == UIApplicationState.Active ){ // receive notif on foreground
            badge++
            Utilities.updateNotificationBadge()
        } else {
            if let route = userInfo["route"] as? String{
                dispatch_async(dispatch_get_main_queue()) {
                    XAppDelegate.mobilePlatform.router.handleRoute(route)
                }
            }
        }
        
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        if ( application.applicationState == UIApplicationState.Active ){ // receive notif on foreground
            // do nothing
        } else {
            XAppDelegate.mobilePlatform.router.handleRoute("/today")
        }
    }
    
    // Route handle
    // MARK: Router handler
    
    func setupRouter(){
        router.addRoute("/today") { (param) -> Void in
            print("Route == horoscope today param dict = \(param)")
        }
        
        router.addRoute("/fortune", blockCode: { (param) -> Void in
            dispatch_async(dispatch_get_main_queue(),{
                Utilities.popCurrentViewControllerToTop()
                if(XAppDelegate.window!.rootViewController!.isKindOfClass(UITabBarController)){
                    let rootVC = XAppDelegate.window!.rootViewController! as? UITabBarController
                    rootVC?.selectedIndex = 0
                }
                if let dailyTableViewController = Utilities.getViewController(DailyTableViewController.classForCoder()) as? DailyTableViewController {
                    dailyTableViewController.cookieTapped()
                }
                
            })
        })
        
        router.addRoute("/horoscope/:date") { (param) -> Void in
            print("Route == horoscope date param dict = \(param)")
        }
        
        router.addRoute("/archive", blockCode: { (param) -> Void in
            dispatch_async(dispatch_get_main_queue(),{
                Utilities.popCurrentViewControllerToTop()
                if(XAppDelegate.window!.rootViewController!.isKindOfClass(UITabBarController)){
                    let rootVC = XAppDelegate.window!.rootViewController! as? UITabBarController
                    rootVC?.selectedIndex = 0
                }
                if let dailyTableViewController = Utilities.getViewController(DailyTableViewController.classForCoder()) as? DailyTableViewController {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateViewControllerWithIdentifier("ArchiveViewController") as! ArchiveViewController
                    dailyTableViewController.navigationController?.pushViewController(controller, animated: true)
                }
                
            })
        })
        
        router.addRoute("/archive/:date/:sign", blockCode: { (param) -> Void in
            print("Route == archive param dict = \(param)")
        })
        
        router.addRoute("/feed/global", blockCode: { (param) -> Void in
            print("Route == global param dict = \(param)")
        })
        
        router.addRoute("/feed/following", blockCode: { (param) -> Void in
            print("Route == feed following param dict = \(param)")
        })
        
        router.addRoute("/today/:id/:post_id/*info", blockCode: { (param) -> Void in
            print("Route == today param dict = \(param)")
        })
        
        router.addRoute("/profile/me/feed", blockCode: { (param) -> Void in
            dispatch_async(dispatch_get_main_queue(),{
                Utilities.popCurrentViewControllerToTop()
                if(XAppDelegate.window!.rootViewController!.isKindOfClass(UITabBarController)){
                    let rootVC = XAppDelegate.window!.rootViewController! as? UITabBarController
                    rootVC?.selectedIndex = 3
                }
            })
        })
        
        router.addRoute("/profile/:uid/feed", blockCode: { (param) -> Void in
            dispatch_async(dispatch_get_main_queue(),{
                Utilities.popCurrentViewControllerToTop()
                if(XAppDelegate.window!.rootViewController!.isKindOfClass(UITabBarController)){
                    let rootVC = XAppDelegate.window!.rootViewController! as? UITabBarController
                    rootVC?.selectedIndex = 3
                }
                let uid = param["uid"] as! String
                Utilities.showHUD()
                SocialManager.sharedInstance.getProfile(uid, completionHandler: { (result, error) -> Void in
                    Utilities.hideHUD()
                    if let _ = error {
                        
                    } else {
                        
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let userProfile = result![0]
                        let controller = storyboard.instantiateViewControllerWithIdentifier("OtherProfileViewController") as! OtherProfileViewController
                        controller.userProfile = userProfile
//                        controller.isPushedFromNotification = true
                        if let profileViewController = Utilities.getViewController(ProfileBaseViewController.classForCoder()) as? ProfileBaseViewController {
                            profileViewController.navigationController?.pushViewController(controller, animated: true)
                        }
                    }
                })
            })
            
        })
        
        router.addRoute("/profile/:uid/followers", blockCode: { (param) -> Void in
            print("Route == followers param dict = \(param)")
        })
        
        router.addRoute("/profile/:uid/following", blockCode: { (param) -> Void in
            print("Route == following param dict = \(param)")
        })
        
        router.addRoute("/profile/me", blockCode: { (param) -> Void in
            print("Route == profile me param dict = \(param)")
        })
        
        router.addRoute("/profile/me/setsign", blockCode: { (param) -> Void in
            print("Route == profile me setsign param dict = \(param)")
        })
        
        router.addRoute("/profile/me/findfriends", blockCode: { (param) -> Void in
            print("Route == profile findfriends param dict = \(param)")
        })
        
        router.addRoute("/post/:post_id", blockCode: { (param) -> Void in
            print("Route == post with param dict = \(param)")
        })
        
        router.addRoute("/post/:post_id/hearts", blockCode: { (param) -> Void in
            dispatch_async(dispatch_get_main_queue(),{
                Utilities.popCurrentViewControllerToTop()
                if(XAppDelegate.window!.rootViewController!.isKindOfClass(UITabBarController)){
                    let rootVC = XAppDelegate.window!.rootViewController! as? UITabBarController
                    rootVC?.selectedIndex = 2
                }
                if let postId = param["post_id"] as? String{
                    Utilities.showHUD()
                    XAppDelegate.socialManager.getPost(postId, completionHandler: { (result, error) -> Void in
                        Utilities.hideHUD()
                        if let _ = error {
                            
                        } else {
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            if let result = result {
                                for post : UserPost in result {
                                    let controller = storyboard.instantiateViewControllerWithIdentifier("SinglePostViewController") as! SinglePostViewController
                                    controller.userPost = post
                                    if let notificationViewController = Utilities.getViewController(NotificationViewController.classForCoder()) as? NotificationViewController {
                                        notificationViewController.navigationController?.pushViewController(controller, animated: true)
                                    }
                                }
                            }
                        }
                    })
                }
            })
            
        })
        
        router.addRoute("/settings", blockCode: { (param) -> Void in
            dispatch_async(dispatch_get_main_queue(),{
                Utilities.popCurrentViewControllerToTop()
                if(XAppDelegate.window!.rootViewController!.isKindOfClass(UITabBarController)){
                    let rootVC = XAppDelegate.window!.rootViewController! as? UITabBarController
                    rootVC?.selectedIndex = 4
                }
            })
        })
        
        // set router default handler which will redirect to main page
        router.addDefaultHandler { () -> Void in
            dispatch_async(dispatch_get_main_queue(),{
                if(XAppDelegate.window!.rootViewController!.isKindOfClass(UITabBarController)){
                    let rootVC = XAppDelegate.window!.rootViewController! as? UITabBarController
                    rootVC?.selectedIndex = 0
                }
            })
        }
    }
}

