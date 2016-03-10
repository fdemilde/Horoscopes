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
    
    var lastGetAllNotificationsTs = 0 as Double // have to put it here for easy reset
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        // hide status bar
        UIApplication.sharedApplication().statusBarHidden = true
        router = XAppDelegate.mobilePlatform.router
        setupRouter()
        self.setupGAITracker()
        horoscopesManager.getHoroscopesSigns() // setup Horo array
        currentUser = NSKeyedUnarchiver.unarchiveObjectWithFile(UserProfile.filePath) as? UserProfile ?? UserProfile()
//        print("didFinishLaunchingWithOptions currentUser == \(currentUser.uid)")
        
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
                let url = value as! NSURL
                let label = "Type = web, Route = \(url.absoluteString)"
                XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.extLaunch, label: label)
                self.getRouteAndHandle(url.absoluteString)
            }
        } else {
            let label = "Type = homescreen"
            XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.extLaunch, label: label)
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
                return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
            }
            route += host
        }
        if let path = url.path {
            route += path
        }
        let label = "Type = web, Route = \(route)"
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.extLaunch, label: label)
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
        } else {
            _value = Int(value)
        }
        
        let udid = XAppDelegate.mobilePlatform.userCred.getUDID()
        let dict = GAIDictionaryBuilder.createEventWithCategory(udid, action: eventName.rawValue, label: label, value: NSNumber(int: Int32(_value))).build() as NSDictionary
        
        GAI.sharedInstance().defaultTracker.send(dict as [NSObject : AnyObject])
        
        let priority = EventConfig.getLogLevel(eventName)
        if let label = label {
            XAppDelegate.mobilePlatform.tracker .logWithAction(eventName.rawValue, label: String(format:"%@",label), priority: priority)
        } else {
            XAppDelegate.mobilePlatform.tracker .logWithAction(eventName.rawValue, label: "", priority: priority)
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
        let latlon = "10.714407,106.735349"
        XAppDelegate.socialManager.sendUserUpdateLocation(latlon, completionHandler: { (result, error) -> Void in
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
    
    func finishedGettingLocation(location : CLLocation){
        // only update once
        let lastLocationDict = NSUserDefaults.standardUserDefaults().objectForKey(LAST_LOCATION_DICT_KEY)
        let locationExpireTime = NSUserDefaults.standardUserDefaults().doubleForKey(LAST_LOCATION_EXPIRE_TIME_KEY)
        // expire in 1 week
        if NSDate().timeIntervalSince1970 >= locationExpireTime {
            updateLocationToServer(location)
            return
        }
        // if first time getting location or current location is 10,000m away from last location, update location to server
        if let lastLocationValue = lastLocationDict as? Dictionary<String, Double>{
            let lat = lastLocationValue["lat"]
            let lon = lastLocationValue["lon"]
            let lastLocation = CLLocation(latitude: lat!, longitude: lon!)
            let distance = location.distanceFromLocation(lastLocation)
            if distance >= 10000 {
                updateLocationToServer(location)
            }
        } else {
            updateLocationToServer(location)
        }
    }
    
    func updateLocationToServer(location : CLLocation){
        var locationDict = Dictionary<String, Double>()
        locationDict["lat"] = location.coordinate.latitude
        locationDict["lon"] = location.coordinate.longitude
        NSUserDefaults.standardUserDefaults().setObject(locationDict, forKey: LAST_LOCATION_DICT_KEY)
        NSUserDefaults.standardUserDefaults().setObject(NSDate().timeIntervalSince1970 + (7*86400), forKey: LAST_LOCATION_EXPIRE_TIME_KEY)
        let latlon = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        XAppDelegate.socialManager.sendUserUpdateLocation(latlon, completionHandler: { (result, error) -> Void in
            if(error == nil){
                let errorCode = result?["error"] as! Int
                if(errorCode == 0){
                    XAppDelegate.socialManager.persistUserProfile(true, completionHandler: { (profileError) -> Void in
                        if(profileError != nil) {
                        } else {
                        }
                    })
                } else {
                    print("Error code === \(errorCode)")
                }
            } else {
                print("Error === \(error)")
            }
        })
    }
    
    // MARK: Notification handler
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let deviceTokenString = String(format:"%@",deviceToken)
        var notificationInfo = "success = "
        if(Utilities.isNotificationGranted()){
            notificationInfo += "1"
        } else {
            notificationInfo += "0"
        }
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: V2_NOTIF_CHECK)
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.permNotification, label: notificationInfo)
        XAppDelegate.socialManager.registerServerNotificationToken(deviceTokenString)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
//        print("didFailToRegisterForRemoteNotificationsWithError error === \(error)")
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: V2_NOTIF_CHECK)
        let notificationInfo = "success = 0"
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.permNotification, label: notificationInfo)
    }
    
    // ios 8
    
    @available(iOS 8.0, *)
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
//        NSLog("didRegisterUserNotificationSettings notificationSettings = \(notificationSettings)")
        application.registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
        XAppDelegate.lastGetAllNotificationsTs = 0 // reset to force notification page reload
        if ( application.applicationState == UIApplicationState.Active ){ // receive notif on foreground
            badge++
            Utilities.updateNotificationBadge()
        } else {
            if let notifId = userInfo["notification_id"]{
                let notifIdString = notifId as! String
                var notificationIds = Set<String>()
                if let notifData = NSUserDefaults.standardUserDefaults().dataForKey(notificationKey) {
                    notificationIds = NSKeyedUnarchiver.unarchiveObjectWithData(notifData) as! Set<String>
                }
                
                if !notificationIds.contains(notifIdString) {
                    notificationIds.insert(notifIdString)
                    let data = NSKeyedArchiver.archivedDataWithRootObject(notificationIds)
                    NSUserDefaults.standardUserDefaults().setObject(data, forKey: notificationKey)
                    SocialManager.sharedInstance.clearNotificationWithId(notifIdString)
                }
            }
            var label = "Type = web"
            if let route = userInfo["route"] as? String{
                dispatch_async(dispatch_get_main_queue()) {
                    label += ", Route = \(route)"
                    XAppDelegate.mobilePlatform.router.handleRoute(route)
                }
            }
            XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.extLaunch, label: label)
        }
        
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        if ( application.applicationState == UIApplicationState.Active ){ // receive notif on foreground
            // do nothing
        } else {
            let label = "Type = local notification"
            XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.extLaunch, label: label)
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
                            if let result = result {
                                let userProfile = result[0]
                                let controller = storyboard.instantiateViewControllerWithIdentifier("OtherProfileViewController") as! OtherProfileViewController
                                controller.userProfile = userProfile
                                //                            controller.isPushedFromNotification = true
                                if let profileViewController = Utilities.getViewController(ProfileBaseViewController.classForCoder()) as? ProfileBaseViewController {
                                    profileViewController.navigationController?.pushViewController(controller, animated: true)
                                }
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
        
        router.addRoute("/post/:post_id", blockCode: { (param) -> Void in
            dispatch_async(dispatch_get_main_queue(),{
                self.gotoPost(param)
            })
        })
        
        router.addRoute("/post/:post_id/hearts", blockCode: { (param) -> Void in
            dispatch_async(dispatch_get_main_queue(),{
                self.gotoPost(param, popUpLikeDetail: true)
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
    
    // MARK: Route Helper
    
    func gotoPost(param : Dictionary<NSObject, AnyObject>, popUpLikeDetail : Bool? = false){
        dispatch_async(dispatch_get_main_queue(),{
            
//            print("Go to post param == \(param)")
//            NSLog("gotoPost == %@", param)
            Utilities.popCurrentViewControllerToTop()
            if(XAppDelegate.window!.rootViewController!.isKindOfClass(UITabBarController)){
                let rootVC = XAppDelegate.window!.rootViewController! as? UITabBarController
                rootVC?.selectedIndex = 3
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
//                                print("result gotopost == \(result)")
                                for post : UserPost in result {
                                    let controller = storyboard.instantiateViewControllerWithIdentifier("SinglePostViewController") as! SinglePostViewController
                                    controller.userPost = post
                                    if let notificationViewController = Utilities.getViewController(NotificationViewController.classForCoder()) as? NotificationViewController {
                                        notificationViewController.navigationController?.pushViewController(controller, animated: true)
                                        if((popUpLikeDetail) != nil && popUpLikeDetail == true) {
                                            self.popupLikeDetail(controller, post: post)
                                        }
                                    }
                                }
                            }
                        }
                    })
                })
            }
        })
    }
    
    func popupLikeDetail(fromViewController : UIViewController, post : UserPost){
        if SocialManager.sharedInstance.isLoggedInFacebook() {
            let postId = post.post_id
            SocialManager.sharedInstance.retrieveUsersWhoLikedPost(postId, page: 0) { (result, error) -> Void in
                if(error != ""){
                    Utilities.showAlert(fromViewController, title: "Action Denied", message: "\(error)", error: nil)
                } else {
                    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = storyBoard.instantiateViewControllerWithIdentifier("LikeDetailTableViewController") as! LikeDetailTableViewController
                    viewController.postId = postId
                    viewController.userProfile = result!.0
                    viewController.parentVC = viewController
                    viewController.numberOfLike = post.hearts
                    self.displayViewController(viewController, fromViewController: fromViewController)
                }
            }
        } else {
            Utilities.showAlert(fromViewController, title: "Action Denied", message: "Please login via Facebook to perform this action", error: nil)
        }
    }
    
    // MARK: display View controller
    func displayViewController(viewController : UIViewController, fromViewController : UIViewController){
        dispatch_async(dispatch_get_main_queue()) {
            let paddingTop = (DeviceType.IS_IPHONE_4_OR_LESS) ? 50 : 70 as CGFloat
            let formSheet = MZFormSheetController(viewController: viewController)
            formSheet.transitionStyle = MZFormSheetTransitionStyle.Fade
            formSheet.shouldDismissOnBackgroundViewTap = true
            formSheet.portraitTopInset = paddingTop;
            formSheet.presentedFormSheetSize = CGSizeMake(Utilities.getScreenSize().width - 20, Utilities.getScreenSize().height - paddingTop * 2)
            fromViewController.mz_presentFormSheetController(formSheet, animated: true, completionHandler: nil)
        }
    }
}

