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
    
    @IBAction func cancelTapped(_ sender: AnyObject) {
        self.mz_dismissFormSheetController(animated: true, completionHandler:nil)
    }
    
    
    @IBAction func logoutTapped(_ sender: AnyObject) {
        let label = "uid = \(XAppDelegate.currentUser.uid)"
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.settingsLogout, label: label)
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        XAppDelegate.socialManager.clearNotification()
        XAppDelegate.dataStore.clearData()
        XAppDelegate.socialManager.logoutZwigglers { (responseDict, error) -> Void in
            print("logoutZwigglers responseDict == \(responseDict)")
        }
        self.mz_dismissFormSheetController(animated: true, completionHandler: { (formSheetController) -> Void in
            self.parentVC.tableView.reloadData()
        })
    }
    
}
