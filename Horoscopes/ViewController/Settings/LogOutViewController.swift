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
        let label = "uid = \(XAppDelegate.currentUser.uid)"
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.settingsLogout, label: label)
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
        if let notificationViewController = Utilities.getViewController(NotificationViewController.classForCoder()) {
            let notificationVC = notificationViewController as! NotificationViewController
            XAppDelegate.socialManager.clearAllNotification(notificationVC.notifArray)
        }
    }
}