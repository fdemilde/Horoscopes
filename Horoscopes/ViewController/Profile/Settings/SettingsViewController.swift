//
//  SettingsViewController.swift
//  Horoscopes
//
//  Created by Binh Dang on 7/20/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
class SettingsViewController: MyViewController, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var birthday : NSDate!
    var birthdayString : String!
    var isNotificationOn = XAppDelegate.userSettings.notifyOfNewHoroscope
    
    // we must save last value of notification setting so when user tap save we can check if it changes or not
    var isLastSaveNotifOn = XAppDelegate.userSettings.notifyOfNewHoroscope
    var notificationFireTime : String!
    var lastSaveNotificationFireTime : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var image = Utilities.getImageToSupportSize("background", size: self.view.frame.size, frame: self.view.bounds)
        self.view.backgroundColor = UIColor(patternImage: image)
        self.birthday = XAppDelegate.userSettings.birthday
        self.getNotificationFireTime()
    }
    
    // MARK: - Table view datasource and delegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 4
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 56
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
        if(indexPath.row == 3){ // last row doesn't need separator
            cell.separator.hidden == true
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.row) {
            case 0:
                var timePickerViewController = self.setupTimePickerViewController()
                self.displayViewController(timePickerViewController)
                break
            case 1:
                var birthdayViewController = self.setupBirthdayViewController()
                self.displayViewController(birthdayViewController)
                break
            case 2:
                var bugsReportViewController = self.setupBugsReportViewController()
                self.displayViewController(bugsReportViewController)
                break
            case 3:
//                showLogoutAlertView()
                break
            default:
                break
        }
    }
    
    // MARK: Setup and display View Controller
    
    func setupBirthdayViewController() -> UIViewController {
        let selectBirthdayVC = self.storyboard!.instantiateViewControllerWithIdentifier("MyDatePickerViewController") as! MyDatePickerViewController
        selectBirthdayVC.setupViewController(self, type: BirthdayParentViewControllerType.SettingsViewController, currentSetupBirthday: birthday)
        return selectBirthdayVC
    }
    
    func setupBugsReportViewController() -> UIViewController {
        let bugsReportViewController = self.storyboard!.instantiateViewControllerWithIdentifier("BugReportViewController") as! BugReportViewController
        return bugsReportViewController
    }
    
    func setupTimePickerViewController() -> UIViewController {
        let timePickerVC = self.storyboard!.instantiateViewControllerWithIdentifier("MyTimePickerViewController") as! MyTimePickerViewController
        timePickerVC.parentVC = self
        return timePickerVC
    }
    
    // MARK: Button action
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.mz_dismissFormSheetControllerAnimated(true, completionHandler:nil)
//        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        self.saveNotificationSetting()
        self.saveBirthdaySetting()
        self.mz_dismissFormSheetControllerAnimated(true, completionHandler:nil)
//        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: save changes
    func saveBirthdaySetting(){
        if(XAppDelegate.userSettings.birthday != self.birthday){
            XAppDelegate.userSettings.birthday = self.birthday
            if(self.birthdayString != nil){
                XAppDelegate.horoscopesManager.sendUpdateBirthdayRequest(birthdayString, completionHandler: { (responseDict, error) -> Void in
                    if(error == nil){
                        XAppDelegate.userSettings.horoscopeSign = Int32(XAppDelegate.horoscopesManager.getSignIndexOfDate(self.birthday))
                        let customTabBarController = XAppDelegate.window!.rootViewController as! CustomTabBarController
                        customTabBarController.selectedSign = Int(XAppDelegate.userSettings.horoscopeSign)
                        customTabBarController.reload()
                    }
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
    
    func finishedSelectingBirthday(dateString : String){
        self.birthdayString = dateString
    }
    
    func displayViewController(viewController : UIViewController){
        var formSheet = MZFormSheetController(viewController: viewController)
        formSheet.transitionStyle = MZFormSheetTransitionStyle.SlideFromBottom;
        formSheet.cornerRadius = 0.0;
        formSheet.portraitTopInset = 0.0;
        formSheet.presentedFormSheetSize = Utilities.getScreenSize()
        
        XAppDelegate.window?.rootViewController?.mz_presentFormSheetController(formSheet, animated: true, completionHandler: nil)
    }
    
    func getNotificationFireTime(){
        
        var array = UIApplication.sharedApplication().scheduledLocalNotifications
        if(array.count > 0){ // have notification setup already
            notificationFireTime = Utilities.getDateStringFromTimestamp(array[0].fireDate.timeIntervalSince1970, dateFormat: NOTIFICATION_SETTING_DATE_FORMAT)
            lastSaveNotificationFireTime = notificationFireTime
        } else {
            notificationFireTime = NOTIFICATION_SETTING_DEFAULT_TIME
            lastSaveNotificationFireTime = notificationFireTime
        }
    }
    
    func doneSelectingTime(){
        
        if(!isNotificationOn){
            isNotificationOn = true
        }
        tableView.reloadData()
    }
    
    // MARK: helpers
    func setLocalPush(){
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        var localNotification = UILocalNotification()
        let components = NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitSecond
        var dateComps = NSCalendar.currentCalendar().components(components, fromDate: NSDate().dateByAddingTimeInterval(24*3600)) // tomorrow date components
        var selectedTime = self.getSelectedTime()
        dateComps.hour = selectedTime.hour
        dateComps.minute = selectedTime.minute
        dateComps.second = 0
        
        var alertTime = NSCalendar.currentCalendar().dateFromComponents(dateComps)
        localNotification.fireDate = alertTime
        localNotification.timeZone = NSTimeZone.defaultTimeZone()
        localNotification.repeatInterval = NSCalendarUnit.CalendarUnitDay
        localNotification.alertBody = "Your Horoscope has arrived"
        localNotification.soundName = "Glass.aiff"
        localNotification.applicationIconBadgeNumber = 1
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    
    func getSelectedTime() -> NSDateComponents{
        let components = NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitSecond
        var date = Utilities.getDateFromDateString(notificationFireTime, format: NOTIFICATION_SETTING_DATE_FORMAT)
        
        return NSCalendar.currentCalendar().components(components, fromDate: date)
    }
    
    func sendSetNotificationTracker(label: String){
        XAppDelegate.sendTrackEventWithActionName(defaultChangeSetting, label: label, value: XAppDelegate.mobilePlatform.tracker.appOpenCounter)
    }
    
    func showLogoutAlertView(){
        dispatch_async(dispatch_get_main_queue(),{
            var alertView: UIAlertView = UIAlertView()
            alertView.delegate = self
            alertView.title = "Log Out"
            alertView.message = "Are you sure you want to log out?"
            alertView.addButtonWithTitle("Yes")
            alertView.addButtonWithTitle("Cancel")
            alertView.show()
        })
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        switch buttonIndex{
        case 0:
            println("YES")
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
        case 1:
            println("NO")
        default:
            println("ERROR")
        }
        
    }
}
