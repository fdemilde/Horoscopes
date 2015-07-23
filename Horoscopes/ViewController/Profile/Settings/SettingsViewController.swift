//
//  SettingsViewController.swift
//  Horoscopes
//
//  Created by Binh Dang on 7/20/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
class SettingsViewController: MyViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var birthday : NSDate!
    var birthdayString : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var image = Utilities.getImageToSupportSize("background", size: self.view.frame.size, frame: self.view.bounds)
        self.view.backgroundColor = UIColor(patternImage: image)
        self.birthday = XAppDelegate.userSettings.birthday
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
                break
            default:
                break
        }
    }
    
    func setupBirthdayViewController() -> UIViewController {
        let selectBirthdayVC = self.storyboard!.instantiateViewControllerWithIdentifier("MyDatePickerViewController") as! MyDatePickerViewController
        selectBirthdayVC.setupViewController(self, type: BirthdayParentViewControllerType.SettingsViewController, currentSetupBirthday: birthday)
        return selectBirthdayVC
    }
    
    func setupBugsReportViewController() -> UIViewController {
        let bugsReportViewController = self.storyboard!.instantiateViewControllerWithIdentifier("BugReportViewController") as! BugReportViewController
        return bugsReportViewController
    }
    
    func displayViewController(viewController : UIViewController){
        var formSheet = MZFormSheetController(viewController: viewController)
        formSheet.transitionStyle = MZFormSheetTransitionStyle.SlideFromBottom;
        formSheet.cornerRadius = 0.0;
        formSheet.portraitTopInset = 0.0;
        formSheet.presentedFormSheetSize = Utilities.getScreenSize()
        
        XAppDelegate.window?.rootViewController?.mz_presentFormSheetController(formSheet, animated: true, completionHandler: nil)
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        if(XAppDelegate.userSettings.birthday != self.birthday){
            XAppDelegate.userSettings.birthday = self.birthday
            if(self.birthdayString != nil){
                XAppDelegate.horoscopesManager.sendUpdateBirthdayRequest(birthdayString, completionHandler: { (responseDict, error) -> Void in
                })
            }
            
        }
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    func finishedSelectingBirthday(dateString : String){
        self.birthdayString = dateString
    }
    
    
}
