//
//  SettingsViewController.swift
//  Horoscopes
//
//  Created by Binh Dang on 7/20/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
class SettingsViewController: ViewControllerWithAds, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var tableHeaderView : UIView!
    var tableFooterView : UIView!
    var birthday : NSDate!
    var birthdayString : String!
    var isNotificationOn = XAppDelegate.userSettings.notifyOfNewHoroscope
    @IBOutlet weak var titleBackgroundView: UIView!
    
    let POPUP_NOTIFICATION_SIZE = CGSizeMake(Utilities.getScreenSize().width - 40, 220)
    let POPUP_DOB_SIZE = CGSizeMake(Utilities.getScreenSize().width - 40, 220)
    let POPUP_BUG_REPORT_SIZE = Utilities.getScreenSize()
    let POPUP_LOG_OUT_SIZE = CGSizeMake(Utilities.getScreenSize().width - 40, 190)
    let TABLE_ROW_HEIGHT = 56 as CGFloat
    
    // we must save last value of notification setting so when user tap save we can check if it changes or not
    var isLastSaveNotifOn = XAppDelegate.userSettings.notifyOfNewHoroscope
    var notificationFireTime : String!
    var lastSaveNotificationFireTime : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = Utilities.getImageToSupportSize("background", size: self.view.frame.size, frame: self.view.bounds)
        self.view.backgroundColor = UIColor(patternImage: image)
        
        titleBackgroundView.layer.shadowOffset = CGSizeMake(0, 1)
        titleBackgroundView.layer.shadowRadius = 2.0
        titleBackgroundView.layer.shadowColor = UIColor.blackColor().CGColor
        titleBackgroundView.layer.shadowOpacity = 0.2
        tableView.layer.cornerRadius = 4
        tableView.clipsToBounds = true
        self.birthday = XAppDelegate.userSettings.birthday
        self.getNotificationFireTime()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
    }
    
    // MARK: - Table view datasource and delegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        tableView.tableHeaderView = getHeaderView()
        tableView.tableFooterView = getFooterView()
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(XAppDelegate.socialManager.isLoggedInFacebook()){
            return 4
        }
        // if not login, do not show log out
        return 3
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return TABLE_ROW_HEIGHT
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : SettingsTableCell!
        cell = tableView.dequeueReusableCellWithIdentifier("SettingsTableCell", forIndexPath: indexPath) as! SettingsTableCell
        switch (indexPath.row) {
            case 0:
                cell.parentVC = self
                cell.setupCell(SettingsType.Notification)
                break
            case 1:
                cell.parentVC = self
                cell.setupCell(SettingsType.ChangeDOB)
                break
            case 2:
                cell.setupCell(SettingsType.BugsReport)
                    break
            case 3:
                cell.setupCell(SettingsType.Logout)
                break
            default:
                break
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.row) {
            case 0:
                let timePickerViewController = self.setupNotificationTimePickerViewController()
                self.displayViewController(timePickerViewController, type: SettingsType.Notification)
                break
            case 1:
                let birthdayViewController = self.setupBirthdayViewController()
                self.displayViewController(birthdayViewController, type: SettingsType.ChangeDOB)
                break
            case 2:
                let bugsReportViewController = self.setupBugsReportViewController()
                self.displayViewController(bugsReportViewController, type: SettingsType.BugsReport)
                break
            case 3:
                let logOutViewController = self.setupLogoutViewController()
                self.displayViewController(logOutViewController, type: SettingsType.Logout)
                break
            default:
                break
        }
    }
    
    // MARK: Setup and display View Controller
    
    func setupNotificationTimePickerViewController() -> UIViewController {
        let timePickerVC = self.storyboard!.instantiateViewControllerWithIdentifier("MyTimePickerViewController") as! MyTimePickerViewController
        timePickerVC.parentVC = self
        return timePickerVC
    }
    
    func setupBirthdayViewController() -> UIViewController {
        let selectBirthdayVC = self.storyboard!.instantiateViewControllerWithIdentifier("MyDatePickerViewController") as! MyDatePickerViewController
        selectBirthdayVC.setupViewController(self, currentSetupBirthday: birthday)
        return selectBirthdayVC
    }
    
    func setupBugsReportViewController() -> UIViewController {
        let bugsReportViewController = self.storyboard!.instantiateViewControllerWithIdentifier("BugReportViewController") as! BugReportViewController
        return bugsReportViewController
    }
    
    func setupLogoutViewController() -> UIViewController {
        let viewController = self.storyboard!.instantiateViewControllerWithIdentifier("LogOutViewController") as! LogOutViewController
        viewController.parentVC = self
        return viewController
    }
    
    // MARK: Button action
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        self.saveNotificationSetting()
        self.saveBirthdaySetting()
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.mode = MBProgressHUDMode.Text
        hud.detailsLabelFont = UIFont.systemFontOfSize(11)
        hud.detailsLabelText = "Saved!"
        hud.hide(true, afterDelay: 2)
    }
    
    // MARK: save changes
    func saveBirthdaySetting(){
        if(XAppDelegate.userSettings.birthday != self.birthday){
            XAppDelegate.userSettings.birthday = self.birthday
            let newSign = Int32(XAppDelegate.horoscopesManager.getSignIndexOfDate(self.birthday))
            if(self.birthdayString != nil){
                XAppDelegate.horoscopesManager.sendUpdateBirthdayRequest(birthdayString, completionHandler: { (responseDict, error) -> Void in
                    if(error == nil){
                        XAppDelegate.userSettings.horoscopeSign = newSign
                        let customTabBarController = XAppDelegate.window!.rootViewController as! CustomTabBarController
                        customTabBarController.selectedSign = Int(XAppDelegate.userSettings.horoscopeSign)
                    }
                })
            }
            
            // update server sign
            if((FBSDKAccessToken .currentAccessToken()) != nil){
                XAppDelegate.socialManager.sendUserUpdateSign(Int(newSign + 1), completionHandler: { (result, error) -> Void in
                })
            }
        }
        
        
    }
    
    func saveNotificationSetting(){
        var label = ""
        // if user didn't change anything
        if((self.isNotificationOn == self.isLastSaveNotifOn) && (self.isNotificationOn == false)){
            return
        }
        
        if((self.isNotificationOn == self.isLastSaveNotifOn) && (self.isNotificationOn == true)){
            // check if user change time or not
            if(self.notificationFireTime == self.lastSaveNotificationFireTime){ // user doesn't change
                return
            } else {
                // change time
                XAppDelegate.userSettings.notifyOfNewHoroscope = isNotificationOn
                self.setLocalPush()
                label = String(format:"alarm_type=%@", "Yes")
                self.sendSetNotificationTracker(label)
                return
            }
        }
        
        if (self.isNotificationOn != self.isLastSaveNotifOn){ // change setting
            var isOnString = ""
            if(self.isNotificationOn){
                self.setLocalPush()
                isOnString = "Yes"
            } else {
                UIApplication.sharedApplication().cancelAllLocalNotifications()
                isOnString = "No"
            }
            XAppDelegate.userSettings.notifyOfNewHoroscope = isNotificationOn
            label = String(format:"alarm_type=%@", isOnString)
            self.sendSetNotificationTracker(label)
            return
        }
    }
    
    // MARK: Helpers
    
    func finishedSelectingBirthday(date : NSDate){
        let dateStringInNumberFormat = self.getDateStringInNumberFormat(date)
        self.birthday = date
        self.birthdayString = dateStringInNumberFormat
        tableView.reloadData()
    }
    
    func displayViewController(viewController : UIViewController, type : SettingsType){
        let formSheet = MZFormSheetController(viewController: viewController)
        formSheet.transitionStyle = MZFormSheetTransitionStyle.Fade
        formSheet.cornerRadius = 0.0;
        if (type == SettingsType.Notification) {
            formSheet.presentedFormSheetSize = POPUP_NOTIFICATION_SIZE
            formSheet.portraitTopInset = ADMOD_HEIGHT + NAVIGATION_BAR_HEIGHT + 10 + TABLE_ROW_HEIGHT
        } else if(type == SettingsType.ChangeDOB){
            formSheet.presentedFormSheetSize = POPUP_DOB_SIZE
            formSheet.portraitTopInset = ADMOD_HEIGHT + NAVIGATION_BAR_HEIGHT + 10 + 2 * TABLE_ROW_HEIGHT
        } else if(type == SettingsType.BugsReport){
            formSheet.transitionStyle = MZFormSheetTransitionStyle.SlideFromBottom
            formSheet.presentedFormSheetSize = POPUP_BUG_REPORT_SIZE
            formSheet.portraitTopInset = 0.0;
        } else {
            formSheet.presentedFormSheetSize = POPUP_LOG_OUT_SIZE
            formSheet.portraitTopInset = ADMOD_HEIGHT + NAVIGATION_BAR_HEIGHT + 10 + TABLE_ROW_HEIGHT
        }
        formSheet.view.layer.shadowColor = UIColor.blackColor().CGColor
        formSheet.view.layer.shadowOffset = CGSizeMake(0, 19)
        formSheet.view.layer.shadowRadius = 10
        formSheet.view.layer.shadowOpacity = 0.4
        formSheet.shouldDismissOnBackgroundViewTap = true
        MZFormSheetController.sharedBackgroundWindow().backgroundColor = UIColor.clearColor()
        self.mz_presentFormSheetController(formSheet, animated: true, completionHandler: nil)
    }
    
    func getNotificationFireTime(){
        
        let array = UIApplication.sharedApplication().scheduledLocalNotifications
        if let array = array {
            if(array.count > 0){ // have notification setup already
                notificationFireTime = Utilities.getDateStringFromTimestamp(array[0].fireDate!.timeIntervalSince1970, dateFormat: NOTIFICATION_SETTING_DATE_FORMAT)
                lastSaveNotificationFireTime = notificationFireTime
            } else {
                notificationFireTime = NOTIFICATION_SETTING_DEFAULT_TIME
                lastSaveNotificationFireTime = notificationFireTime
            }
        }
        
    }
    
    func doneSelectingTime(time : NSDate){
        
        if(!isNotificationOn){
            isNotificationOn = true
        }
        
        notificationFireTime = Utilities.getDateStringFromTimestamp(time.timeIntervalSince1970, dateFormat: NOTIFICATION_SETTING_DATE_FORMAT)
        
        lastSaveNotificationFireTime = notificationFireTime
        tableView.reloadData()
    }
    
    // MARK: helpers
    func setLocalPush(){
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        let localNotification = UILocalNotification()
        let components: NSCalendarUnit = [.Year, .Month, .Day, .Hour, .Minute, .Second]
        let dateComps = NSCalendar.currentCalendar().components(components, fromDate: NSDate().dateByAddingTimeInterval(24*3600)) // tomorrow date components
        let selectedTime = self.getSelectedTime()
        dateComps.hour = selectedTime.hour
        dateComps.minute = selectedTime.minute
        dateComps.second = 0
        
        let alertTime = NSCalendar.currentCalendar().dateFromComponents(dateComps)
//        println("set local push == \(alertTime)")
        localNotification.fireDate = alertTime
        localNotification.timeZone = NSTimeZone.defaultTimeZone()
        localNotification.repeatInterval = [.Day]
        localNotification.alertBody = "Your Horoscope has arrived"
        localNotification.soundName = "Glass.aiff"
        localNotification.applicationIconBadgeNumber = 1
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    
    func getSelectedTime() -> NSDateComponents{
        let components: NSCalendarUnit = [.Year, .Month, .Day, .Hour, .Minute, .Second]
        let date = Utilities.getDateFromDateString(notificationFireTime, format: NOTIFICATION_SETTING_DATE_FORMAT)
        
        return NSCalendar.currentCalendar().components(components, fromDate: date)
    }
    
    func sendSetNotificationTracker(label: String){
        XAppDelegate.sendTrackEventWithActionName(defaultChangeSetting, label: label, value: XAppDelegate.mobilePlatform.tracker.appOpenCounter)
    }
    
    //  MARK: HELPERS
    func getFooterView() -> UIView {
        if let _ = tableFooterView{
            
        } else {
            tableFooterView = UIView()
            tableFooterView.frame = CGRectMake(0, 0, tableView.frame.width, 8)
            tableFooterView.backgroundColor = UIColor.clearColor()
        }
        return tableFooterView
    }
    
    func getHeaderView() -> UIView {
        if let _ = tableHeaderView{
            
        } else {
            tableHeaderView = UIView()
            tableHeaderView.frame = CGRectMake(0, 0, tableView.frame.width, 8)
            tableHeaderView.backgroundColor = UIColor.clearColor()
        }
        return tableHeaderView
    }
    
    func getDateStringInNumberFormat(date : NSDate) -> String{
        let components: NSCalendarUnit = [.Year, .Month, .Day, .Hour, .Minute, .Second]
        let comp = NSCalendar.currentCalendar().components(components, fromDate: date)
        let result = String(format:"%d/%02d", comp.day, comp.month)
        return result
    }
}