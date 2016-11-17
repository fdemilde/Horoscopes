//
//  SettingsViewController.swift
//  Horoscopes
//
//  Created by Binh Dang on 7/20/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
class SettingsViewController: ViewControllerWithAds, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, LoginViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var tableHeaderView : UIView!
    var tableFooterView : UIView!
    var birthday : StandardDate!
    var birthdayString : String!
    var parentVC : CurrentProfileViewController!
//    var isNotificationOn = XAppDelegate.userSettings.notifyOfNewHoroscope
    @IBOutlet weak var titleBackgroundView: UIView!
    
    let POPUP_NOTIFICATION_SIZE = CGSize(width: Utilities.getScreenSize().width - 40, height: 220)
    let POPUP_DOB_SIZE = CGSize(width: Utilities.getScreenSize().width - 40, height: 220)
    let POPUP_BUG_REPORT_SIZE = Utilities.getScreenSize()
    let POPUP_LOG_OUT_SIZE = CGSize(width: Utilities.getScreenSize().width - 40, height: 190)
    let TABLE_ROW_HEIGHT = 56 as CGFloat
    
    // we must save last value of notification setting so when user tap save we can check if it changes or not
//    var isLastSaveNotifOn = XAppDelegate.userSettings.notifyOfNewHoroscope
    var notificationFireTime : String!
    var lastSaveNotificationFireTime : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = Utilities.getImageToSupportSize("background", size: self.view.frame.size, frame: self.view.bounds)
        self.view.backgroundColor = UIColor(patternImage: image)
        
        titleBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 1)
        titleBackgroundView.layer.shadowRadius = 2.0
        titleBackgroundView.layer.shadowColor = UIColor.black.cgColor
        titleBackgroundView.layer.shadowOpacity = 0.2
        tableView.layer.cornerRadius = 4
        tableView.clipsToBounds = true
        self.getNotificationFireTime()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.settingsOpen, label: "")
        self.birthday = XAppDelegate.userSettings.birthday
        self.tableView.reloadData()
    }
    
    // MARK: - Table view datasource and delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        tableView.tableHeaderView = getHeaderView()
        tableView.tableFooterView = getFooterView()
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(XAppDelegate.socialManager.isLoggedInFacebook()){
            return 6
        }
        // if not login, do not show log out
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TABLE_ROW_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : SettingsTableCell!
        cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableCell", for: indexPath) as! SettingsTableCell
        switch (indexPath.row) {
            case 0:
                cell.parentVC = self
                cell.setupCell(SettingsType.notification, title: "Daily Notification")
                break
            case 1:
                cell.parentVC = self
                cell.setupCell(SettingsType.changeDOB, title: "Birthday")
                break
            case 2:
                cell.parentVC = self
                cell.setupCell(SettingsType.changeSign, title: "Horoscope Sign")
                break
            case 3:
                cell.setupCell(SettingsType.bugsReport, title: "Find Facebook friends")
                break
            case 4:
                cell.setupCell(SettingsType.bugsReport, title: "Report a problem")
                break
            case 5:
                cell.setupCell(SettingsType.logout, title: "Logout")
                break
            default:
                break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.row) {
            case 3:
                if SocialManager.sharedInstance.isLoggedInFacebook() && SocialManager.sharedInstance.isLoggedInZwigglers() {
                    XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.fbFriendsOpen, label: nil)
                    let controller = storyboard?.instantiateViewController(withIdentifier: "FacebookFriendViewController") as! FacebookFriendViewController
                    navigationController?.pushViewController(controller, animated: true)
                } else {
                    let controller = storyboard?.instantiateViewController(withIdentifier: "PostLoginViewController") as! PostLoginViewController
                    controller.delegate = self
                    let formSheet = MZFormSheetController(viewController: controller)
                    formSheet.shouldDismissOnBackgroundViewTap = true
                    formSheet.cornerRadius = 5
                    formSheet.shouldCenterVertically = true
                    formSheet.presentedFormSheetSize = CGSize(width: formSheet.view.frame.width, height: 150)
                    self.mz_present(formSheet, animated: true, completionHandler: nil)
                }
            case 0:
                let timePickerViewController = self.setupNotificationTimePickerViewController()
                self.displayViewController(timePickerViewController, type: SettingsType.notification)
                break
            case 1:
                XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.dobOpen, label: nil)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                present(loginVC, animated: true, completion: nil)
                break
            case 2:
                XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.dobOpen, label: nil)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                present(loginVC, animated: true, completion: nil)
                break
            case 4:
                let bugsReportViewController = self.setupBugsReportViewController()
                self.displayViewController(bugsReportViewController, type: SettingsType.bugsReport)
                break
            case 5:
                let logOutViewController = self.setupLogoutViewController()
                self.displayViewController(logOutViewController, type: SettingsType.logout)
                break
            default:
                break
        }
    }
    
    func didLoginSuccessfully() {
        let controller = storyboard?.instantiateViewController(withIdentifier: "FacebookFriendViewController") as! FacebookFriendViewController
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: Setup and display View Controller
    
    func setupNotificationTimePickerViewController() -> UIViewController {
        let timePickerVC = self.storyboard!.instantiateViewController(withIdentifier: "MyTimePickerViewController") as! MyTimePickerViewController
        timePickerVC.parentVC = self
        return timePickerVC
    }
    
    func setupBugsReportViewController() -> UIViewController {
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.settingsBug, label: nil)
        let bugsReportViewController = self.storyboard!.instantiateViewController(withIdentifier: "BugReportViewController") as! BugReportViewController
        return bugsReportViewController
    }
    
    func setupLogoutViewController() -> UIViewController {
        let viewController = self.storyboard!.instantiateViewController(withIdentifier: "LogOutViewController") as! LogOutViewController
        viewController.parentVC = self
        return viewController
    }
    
    // MARK: Button action
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
//    @IBAction func searchButtonTapped(sender: UIButton) {
//        let controller = storyboard?.instantiateViewControllerWithIdentifier("SearchViewController") as! SearchViewController
//        controller.delegate = self.parentVC
//        navigationController?.presentViewController(controller, animated: true, completion: nil)
//    }
    
    @IBAction func saveButtonTapped(_ sender: AnyObject) {
        self.saveNotificationSetting()
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = MBProgressHUDMode.text
        hud.detailsLabelFont = UIFont.systemFont(ofSize: 11)
        hud.detailsLabelText = "Saved!"
        hud.hide(true, afterDelay: 2)
    }
    
    // MARK: save changes
    // MARK: BINH: function is not used but the design is not finalize so let it here, remove later
    
    func sendUpdateSign(_ newSign : Int32){
        
        XAppDelegate.socialManager.sendUserUpdateSign(Int(newSign + 1), completionHandler: { (result, error) -> Void in
            let errorCode = result?["error"] as! Int
            if(errorCode == 0){
                XAppDelegate.socialManager.persistUserProfile(true, completionHandler: { (error) -> Void in
                })
            } else {
                print("Error code === \(errorCode)")
            }
            
        })
    }
    
    func saveNotificationSetting(){
        var label = ""
        if (XAppDelegate.userSettings.notifyOfNewHoroscope == true) {
            Utilities.registerForRemoteNotification()
            Utilities.setLocalPush(self.getSelectedTime())
            label += "enabled = 1"
        } else {
            UIApplication.shared.cancelAllLocalNotifications()
            label += "enabled = 0"
        }
        
        label += ", time = \(notificationFireTime)"
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.settingsNotify, label: label)
    }
    
    // MARK: Helpers
    // MARK: BINH: function is not used but the design is not finalize so let it here, remove later
    func finishedSelectingBirthday(_ date : StandardDate){
        let dateStringInNumberFormat = self.getDateStringInNumberFormat(date)
        self.birthday = date
        self.birthdayString = dateStringInNumberFormat
        tableView.reloadData()
    }
    
    func displayViewController(_ viewController : UIViewController, type : SettingsType){
        let formSheet = MZFormSheetController(viewController: viewController)
        formSheet.transitionStyle = MZFormSheetTransitionStyle.fade
        formSheet.cornerRadius = 0.0;
        if (type == SettingsType.notification) {
            formSheet.presentedFormSheetSize = POPUP_NOTIFICATION_SIZE
            formSheet.portraitTopInset = ADMOD_HEIGHT + NAVIGATION_BAR_HEIGHT + 10 + TABLE_ROW_HEIGHT
        } else if(type == SettingsType.changeDOB){
            formSheet.presentedFormSheetSize = POPUP_DOB_SIZE
            formSheet.portraitTopInset = ADMOD_HEIGHT + NAVIGATION_BAR_HEIGHT + 10 + 2 * TABLE_ROW_HEIGHT
        } else if(type == SettingsType.bugsReport){
            formSheet.transitionStyle = MZFormSheetTransitionStyle.slideFromBottom
            formSheet.presentedFormSheetSize = POPUP_BUG_REPORT_SIZE
            formSheet.portraitTopInset = 0.0;
        } else {
            formSheet.presentedFormSheetSize = POPUP_LOG_OUT_SIZE
            formSheet.portraitTopInset = ADMOD_HEIGHT + NAVIGATION_BAR_HEIGHT + 10 + TABLE_ROW_HEIGHT
        }
        formSheet.view.layer.shadowColor = UIColor.black.cgColor
        formSheet.view.layer.shadowOffset = CGSize(width: 0, height: 19)
        formSheet.view.layer.shadowRadius = 10
        formSheet.view.layer.shadowOpacity = 0.4
        formSheet.shouldDismissOnBackgroundViewTap = true
        MZFormSheetController.sharedBackgroundWindow().backgroundColor = UIColor.clear
        self.mz_present(formSheet, animated: true, completionHandler: nil)
    }
    
    func getNotificationFireTime(){
        
        let array = UIApplication.shared.scheduledLocalNotifications
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
    
    func doneSelectingTime(_ time : Date){
        if(XAppDelegate.userSettings.notifyOfNewHoroscope == false){
            XAppDelegate.userSettings.notifyOfNewHoroscope = true
        }
        notificationFireTime = Utilities.getDateStringFromTimestamp(time.timeIntervalSince1970, dateFormat: NOTIFICATION_SETTING_DATE_FORMAT)
        lastSaveNotificationFireTime = notificationFireTime
        self.saveNotificationSetting()
        tableView.reloadData()
    }
    
    // MARK: helpers
    
    func getSelectedTime() -> DateComponents{
        let components: NSCalendar.Unit = [.year, .month, .day, .hour, .minute, .second]
        let date = Utilities.getDateFromDateString(notificationFireTime, format: NOTIFICATION_SETTING_DATE_FORMAT)
        
        return (Calendar.current as NSCalendar).components(components, from: date)
    }
    
    func sendSetNotificationTracker(_ label: String){
//        XAppDelegate.sendTrackEventWithActionName(defaultChangeSetting, label: label, value: XAppDelegate.mobilePlatform.tracker.appOpenCounter)
    }
    
    //  MARK: HELPERS
    func getFooterView() -> UIView {
        if let _ = tableFooterView{
            
        } else {
            tableFooterView = UIView()
            tableFooterView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 8)
            tableFooterView.backgroundColor = UIColor.clear
        }
        return tableFooterView
    }
    
    func getHeaderView() -> UIView {
        if let _ = tableHeaderView{
            
        } else {
            tableHeaderView = UIView()
            tableHeaderView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 8)
            tableHeaderView.backgroundColor = UIColor.clear
        }
        return tableHeaderView
    }
    
    func getDateStringInNumberFormat(_ date : StandardDate) -> String{
        let result = String(format:"%d/%02d", date.day, date.month)
        return result
    }
}
