//
//  NotificationTableViewController.swift
//  Horoscopes
//
//  Created by Dang Doan on 7/8/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

class NotificationViewController: ViewControllerWithAds, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    let MIN_SCROLL_DISTANCE_TO_HIDE_TABBAR = 30 as CGFloat
    let PADDING = 8 as CGFloat
    var startPositionY = 0 as CGFloat
    var notifArray = [NotificationObject]()
    var router : Router!
    var tableHeaderView : UIView!
    var tableFooterView : UIView!
    var noNotificationView : UIView!
    var updateTimer : NSTimer!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        return refreshControl
        }()
    
    var notificationIds = Set<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = Utilities.getImageToSupportSize("background", size: self.view.frame.size, frame: self.view.bounds)
        self.view.backgroundColor = UIColor(patternImage: image)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 4
        tableView.clipsToBounds = true
        tableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "update", userInfo: nil, repeats: true)
        if let notifData = NSUserDefaults.standardUserDefaults().dataForKey(notificationKey) {
            notificationIds = NSKeyedUnarchiver.unarchiveObjectWithData(notifData) as! Set<String>
        }
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        let label = "no_notif = \(notifArray.count)"
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.notifOpen, label: label)
        if(XAppDelegate.badge > 0){
            let retrieveLabel = "no_retrieved = \(XAppDelegate.badge)"
            XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.notifRetrieved, label: retrieveLabel)
        }
        XAppDelegate.badge = 0
        Utilities.updateNotificationBadge()
        let time = NSDate().timeIntervalSince1970 - XAppDelegate.lastGetAllNotificationsTs
        if(time > 60){
            self.getNotificationAndReloadData()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        updateTimer.invalidate()
        updateTimer = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if(notifArray.count != 0 ){
            self.tableView.backgroundView = nil
            return 1
        } else {
            self.tableView.backgroundView = nil
            // Display a message when the table is empty
            let messageLabel = UILabel(frame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
            // This is created to calculate label position
            messageLabel.text = "You have no notifications yet"
            messageLabel.font = UIFont(name: "HelveticaNeue-Light", size:15)
            messageLabel.sizeToFit()
            let view = UIView(frame:CGRectMake(0, 0, tableView.bounds.size.width, tableView.bounds.size.height))
            view.backgroundColor = UIColor.whiteColor()
            // real label
            let fixedLabel = UILabel(frame:CGRectMake((tableView.bounds.size.width - messageLabel.frame.width) / 2, (tableView.bounds.size.height - ADMOD_HEIGHT - messageLabel.frame.height) / 2, messageLabel.frame.width, messageLabel.frame.height))
            fixedLabel.textColor = UIColor.blackColor()
            fixedLabel.numberOfLines = 0
            fixedLabel.textAlignment = NSTextAlignment.Center
            fixedLabel.font = messageLabel.font
            fixedLabel.text = messageLabel.text
            view.addSubview(fixedLabel)
            self.tableView.backgroundView = view
        }
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notifArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : NotificationTableViewCell!
        cell = tableView.dequeueReusableCellWithIdentifier("NotificationTableViewCell", forIndexPath: indexPath) as! NotificationTableViewCell
        if let cell = cell {
            cell.resetUI()
            self.resetCornerRadius(cell)
        }
        cell.populateData(notifArray[indexPath.row])
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let id = notifArray[indexPath.row].notification_id
        if notificationIds.contains(id) {
            cell.backgroundColor = UIColor.whiteColor()
        } else {
            cell.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if let cell = cell {
            cell.backgroundColor = UIColor.whiteColor()
            let id = notifArray[indexPath.row].notification_id
            notificationIds.insert(id)
            let data = NSKeyedArchiver.archivedDataWithRootObject(notificationIds)
            NSUserDefaults.standardUserDefaults().setObject(data, forKey: notificationKey)
            SocialManager.sharedInstance.clearNotificationWithId(id)
            let notifCell = cell as! NotificationTableViewCell
            let route = notifCell.notification.route
            if(route != nil && route != ""){
                let label = "notif_id = \(id) route = \(route)"
                XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.notifSelect, label: label)
//                print("didSelectRowAtIndexPath route == \(route)")
                dispatch_async(dispatch_get_main_queue()) {
                    XAppDelegate.mobilePlatform.router.handleRoute(notifCell.notification.route);
                }
                
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    // MARK: Button actions
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        CacheManager.clearAllNotificationData()
        self.getNotificationAndReloadData()
        refreshControl.endRefreshing()
    }
    
    @IBAction func refreshButtonTapped(sender: AnyObject) {
        self.getNotificationAndReloadData()
    }
    
    @IBAction func clearAllTapped(sender: AnyObject) {
//        XAppDelegate.socialManager.clearAllNotification()
        
    }
    
    // MARK: Helpers
    func getNotificationAndReloadData(){
//        if !SocialManager.sharedInstance.isLoggedInFacebook() {
//            notifArray = [NotificationObject]()
//            tableView.reloadData()
//            return
//        }
        
        if(notifArray.count == 0){ // first load
            Utilities.showHUD()
            tableView.backgroundColor = UIColor.whiteColor()
        }
        XAppDelegate.socialManager.getAllNotification(0, completionHandler: { (result) -> Void in
            if let notifData = NSUserDefaults.standardUserDefaults().dataForKey(notificationKey) {
                self.notificationIds = NSKeyedUnarchiver.unarchiveObjectWithData(notifData) as! Set<String>
            }
            XAppDelegate.lastGetAllNotificationsTs = NSDate().timeIntervalSince1970
//            print("getNotificationAndReloadData == \(result)")
            dispatch_async(dispatch_get_main_queue(),{
                Utilities.hideHUD()
                
                self.tableView.beginUpdates()
                let deltaCalculator = BKDeltaCalculator(equalityTest: { (notif1 , notif2) -> Bool in
                    let n1 = notif1 as! NotificationObject
                    let n2 = notif2 as! NotificationObject
                    return (n1.notification_id == n2.notification_id);
                })
                let delta = deltaCalculator.deltaFromOldArray(self.notifArray, toNewArray:result!)
                delta.applyUpdatesToTableView(self.tableView,inSection:0,withRowAnimation:UITableViewRowAnimation.Fade)
                self.notifArray = result!
                self.notifArray.sortInPlace({ $0.created > $1.created })
//                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
                self.tableView.endUpdates()
                
            })
        })
    }
    
    // MARK: UI Helper
    func getHeaderView() -> UIView {
        if let _ = tableHeaderView{
            
        } else {
            tableHeaderView = UIView()
            tableHeaderView.frame = CGRectMake(0, 0, tableView.frame.width,PADDING)
            tableHeaderView.backgroundColor = UIColor.clearColor()
        }
        return tableHeaderView
    }
    
    func getFooterView() -> UIView {
        if let _ = tableFooterView{
            
        } else {
            tableFooterView = UIView()
            tableFooterView.frame = CGRectMake(0, 0, tableView.frame.width, PADDING)
            tableFooterView.backgroundColor = UIColor.clearColor()
            
        }
        return tableFooterView
    }
    
    // prevent corner radius from applying to middle rows
    func resetCornerRadius(cell : NotificationTableViewCell){
        dispatch_async(dispatch_get_main_queue(),{
            Utilities.makeCornerRadius(cell, maskFrame: cell.bounds, roundOptions: UIRectCorner(), radius: 4.0) as! NotificationTableViewCell
        })
    }
    
    // MARK: update timer
    func update() {
        let visibleCells = self.tableView.visibleCells
        for cell in visibleCells {
            if let castedCell = cell as? NotificationTableViewCell {
                castedCell.updateTimeAgo()
            }
        }
    }
}
