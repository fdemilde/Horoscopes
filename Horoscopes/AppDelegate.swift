//
//  AppDelegate.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/3/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var mobilePlatform = MobilePlatform()
    var userSettings = UserSettings()
    var horoscopesManager = HoroscopesManager()
    var socialManager = SocialManager()
    var currentUser : UserProfile?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        // hide status bar
        UIApplication.sharedApplication().statusBarHidden = true
        self.setupGAITracker()
        
        horoscopesManager.getHoroscopesSigns() // setup Horo array
        horoscopesManager.getAllHoroscopes(false)
        
        if true {
            self.showLoginVC()
        } else {
            
        }
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func showLoginVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier("LoginVC") as! LoginVC
        
        var formSheet = MZFormSheetController(viewController: viewController)
        formSheet.transitionStyle = MZFormSheetTransitionStyle.Fade;
        formSheet.cornerRadius = 0.0;
        formSheet.portraitTopInset = -20.0;
        formSheet.presentedFormSheetSize = CGSizeMake(self.window!.frame.size.width, self.window!.frame.size.height);
        self.window?.rootViewController?.mz_presentFormSheetController(formSheet, animated: true, completionHandler: nil)
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
}

