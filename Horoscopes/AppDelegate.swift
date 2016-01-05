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
        
        XAppDelegate.mobilePlatform.tracker.saveAppOpenCounter()
        if(XAppDelegate.mobilePlatform.tracker.loadAppOpenCountervalue() == 4){ // 4th load will ask for notification permission
            Utilities.registerForRemoteNotification()
        }
        
        if(socialManager.isLoggedInZwigglers()){
            // sendLocation() // for testing
            locationManager.setupLocationService()
        }
        
        if let launchOptions = launchOptions {
            if let value = launchOptions["UIApplicationLaunchOptionsURLKey"] {
//                print("launchOptions open with web link")
                let url = value as! NSURL
                self.getRouteAndHandle(url.absoluteString)
            }
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
        var route = "/"
        if let host = url.host { // if login with facebook in the app, it will redirect here
//            print("application application login facebook in app")
            if host == "authorize" {
//                print("host == authorize")
                return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
            }
            route += host
        }
//        print("application openURL sourceApplication")
        if let path = url.path {
            route += path
        }
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
    
    func sendTrackEventWithActionName(eventName: EventConfig.Event, label:String?, value: Int32 = -1){
        // if the value < 0, we should override it with appOpenCounter value
        var _value = 0
        
        if (value < 0) {
            _value = Int(XAppDelegate.mobilePlatform.tracker.appOpenCounter);
        }
        
        let udid = XAppDelegate.mobilePlatform.userCred.getUDID()
        let dict = GAIDictionaryBuilder.createEventWithCategory(udid, action: eventName.rawValue, label: label, value: NSNumber(int: Int32(_value))).build() as NSDictionary
        
        GAI.sharedInstance().defaultTracker.send(dict as [NSObject : AnyObject])
        
        let priority = EventConfig.getLogLevel(eventName)
        
        if let label = label {
            XAppDelegate.mobilePlatform.tracker .logWithAction(eventName.rawValue, label: String(format:"Open=%i,%@", value,label), priority: priority)
        } else {
            XAppDelegate.mobilePlatform.tracker .logWithAction(eventName.rawValue, label: String(format:"Open=%i", value), priority: priority)
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
        let latlon = "10.714407,106.735349"
            if let data = data {
                let string = NSString(data: data, encoding: NSUTF8StringEncoding)
                XAppDelegate.socialManager.sendUserUpdateLocation(string as? String,latlon: latlon, completionHandler: { (result, error) -> Void in
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
            
            let latlon = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
            let url = NSURL(string: googleLink)
            let session = NSURLSession.sharedSession()
            let dataTask = session.dataTaskWithURL(url!, completionHandler: { (data: NSData?, response:NSURLResponse?,
                error: NSError?) -> Void in
                
                if let data = data {
                    let string = NSString(data: data, encoding: NSUTF8StringEncoding)
                    XAppDelegate.socialManager.sendUserUpdateLocation(string as? String, latlon: latlon, completionHandler: { (result, error) -> Void in
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
        print("didFailToRegisterForRemoteNotificationsWithError error === \(error)")
    }
    
    // ios 8
    
    @available(iOS 8.0, *)
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
//        NSLog("didRegisterUserNotificationSettings notificationSettings")
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
            Utilities.popCurrentViewControllerToTop()
            if(XAppDelegate.window!.rootViewController!.isKindOfClass(UITabBarController)){
                let rootVC = XAppDelegate.window!.rootViewController! as? UITabBarController
                rootVC?.selectedIndex = 0
            }
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
                    rootVC?.selectedIndex = 4
                }
            })
        })
        
        router.addRoute("/profile/:uid/feed", blockCode: { (param) -> Void in
            dispatch_async(dispatch_get_main_queue(),{
                Utilities.popCurrentViewControllerToTop()
                if(XAppDelegate.window!.rootViewController!.isKindOfClass(UITabBarController)){
                    let rootVC = XAppDelegate.window!.rootViewController! as? UITabBarController
                    rootVC?.selectedIndex = 4
                }
                let uid = param["uid"] as! String
                Utilities.showHUD()
                SocialManager.sharedInstance.getProfile(uid, ignoreCache: true, completionHandler: { (result, error) -> Void in
                    dispatch_async(dispatch_get_main_queue(),{
                        Utilities.hideHUD()
                        if let _ = error {
                            
                        } else {
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let userProfile = result![0]
                            let controller = storyboard.instantiateViewControllerWithIdentifier("OtherProfileViewController") as! OtherProfileViewController
                            controller.userProfile = userProfile
//                            controller.isPushedFromNotification = true
                            if let profileViewController = Utilities.getViewController(ProfileBaseViewController.classForCoder()) as? ProfileBaseViewController {
                                profileViewController.navigationController?.pushViewController(controller, animated: true)
                            }
                        }
                    })
                })
            })
            
        })
        
        router.addRoute("/profile/me/followers", blockCode: { (param) -> Void in
            print("Route == me followers param dict = \(param)")
        })
        
        router.addRoute("/profile/:uid/followers", blockCode: { (param) -> Void in
            print("Route == followers param dict = \(param)")
        })
        
        router.addRoute("/profile/me/following", blockCode: { (param) -> Void in
            print("Route ==  /profile/me/following param dict = \(param)")
        })
        
        router.addRoute("/profile/:uid/following", blockCode: { (param) -> Void in
            print("Route == following param dict = \(param)")
        })
        
        router.addRoute("/profile/me/setsign", blockCode: { (param) -> Void in
            print("Route == profile me setsign param dict = \(param)")
        })
        
        router.addRoute("/profile/me/dob", blockCode: { (param) -> Void in
            print("Route == profile dob param dict = \(param)")
        })
        
        router.addRoute("/profile/me/facebookfriends", blockCode: { (param) -> Void in
            print("Route == profile facebookfriends param dict = \(param)")
        })
        
//        print("add route !! == /post/:post_id")
//        NSLog("add route !! == /post/:post_id")
        router.addRoute("/post/:post_id", blockCode: { (param) -> Void in
            print("Route == post with param dict = \(param)")
            dispatch_async(dispatch_get_main_queue(),{
                self.gotoPost(param)
            })
        })
        
//        print("add route !! == /post/:post_id/hearts")
//        NSLog("add route !! == /post/:post_id/hearts")
        router.addRoute("/post/:post_id/hearts", blockCode: { (param) -> Void in
            dispatch_async(dispatch_get_main_queue(),{
                self.gotoPost(param)
            })
        })
        
        router.addRoute("/settings", blockCode: { (param) -> Void in
            dispatch_async(dispatch_get_main_queue(),{
                if(!XAppDelegate.socialManager.isLoggedInFacebook()){
                    return
                }
                Utilities.popCurrentViewControllerToTop()
                if(XAppDelegate.window!.rootViewController!.isKindOfClass(UITabBarController)){
                    let rootVC = XAppDelegate.window!.rootViewController! as? UITabBarController
                    rootVC?.selectedIndex = 4
                }
                if let profileViewController = Utilities.getViewController(CurrentProfileViewController.classForCoder()) as? CurrentProfileViewController {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateViewControllerWithIdentifier("SettingsViewController") as! SettingsViewController
                    controller.parentVC = profileViewController
                    profileViewController.navigationController?.pushViewController(controller, animated: true)
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
    
    func getRouteAndHandle(url : String){
        
        if let schemeRange = url.rangeOfString("zwigglers-horoscopes://") {
            let route = url.substringFromIndex(schemeRange.endIndex)
            XAppDelegate.mobilePlatform.router.handleRoute(route)
        }
    }
    
    func gotoPost(param : Dictionary<NSObject, AnyObject>){
        dispatch_async(dispatch_get_main_queue(),{
            
//            print("Go to post param == \(param)")
//            NSLog("gotoPost == %@", param)
            Utilities.popCurrentViewControllerToTop()
            if(XAppDelegate.window!.rootViewController!.isKindOfClass(UITabBarController)){
                let rootVC = XAppDelegate.window!.rootViewController! as? UITabBarController
                rootVC?.selectedIndex = 1
            }
            if let postId = param["post_id"] as? String{
                Utilities.showHUD()
                XAppDelegate.socialManager.getPost(postId, ignoreCache: true, completionHandler: { (result, error) -> Void in
                    dispatch_async(dispatch_get_main_queue(),{
                        Utilities.hideHUD()
                        if let _ = error {
                            
                        } else {
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            if let result = result {
                                for post : UserPost in result {
                                    let controller = storyboard.instantiateViewControllerWithIdentifier("SinglePostViewController") as! SinglePostViewController
                                    controller.userPost = post
                                    if let notificationViewController = Utilities.getViewController(AlternateCommunityViewController.classForCoder()) as? AlternateCommunityViewController {
                                        notificationViewController.navigationController?.pushViewController(controller, animated: true)
                                    }
                                }
                            }
                        }
                    })
                })
            }
        })
    }
}

