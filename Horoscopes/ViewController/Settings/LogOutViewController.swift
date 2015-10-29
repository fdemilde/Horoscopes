//
//  LogOutViewController.swift
//  Horoscopes
//
//  Created by Binh Dang on 9/15/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
class LogOutViewController : UIViewController {
    
    var parentVC : SettingsViewController!
    
    @IBAction func cancelTapped(sender: AnyObject) {
        self.mz_dismissFormSheetControllerAnimated(true, completionHandler:nil)
    }
    
    
    @IBAction func logoutTapped(sender: AnyObject) {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        self.clearNotification()
        XAppDelegate.dataStore.clearData()
        XAppDelegate.socialManager.logoutZwigglers { (responseDict, error) -> Void in
            print("logoutZwigglers responseDict == \(responseDict)")
        }
        self.mz_dismissFormSheetControllerAnimated(true, completionHandler: { (formSheetController) -> Void in
            self.parentVC.tableView.reloadData()
        })
    }
    
    func clearNotification(){
        if(XAppDelegate.window!.rootViewController!.isKindOfClass(UITabBarController)){
            let tabbarVC = XAppDelegate.window!.rootViewController! as? UITabBarController
            for nav in tabbarVC!.viewControllers! {
                let nav = nav as! UINavigationController
                if let vc = nav.viewControllers.first { // every tab in tabbar vc is a Navigation bar with vc as first element
                    if vc.isKindOfClass( NotificationViewController.classForCoder() ) {
                        let notificationViewController = vc as! NotificationViewController
                        XAppDelegate.socialManager.clearAllNotification(notificationViewController.notifArray)
                    }
                }
            }
        }
    }
}