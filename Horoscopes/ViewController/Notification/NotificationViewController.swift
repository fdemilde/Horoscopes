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
    var updateTimer : Timer!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(NotificationViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(NotificationViewController.update), userInfo: nil, repeats: true)
        if let notifData = UserDefaults.standard.data(forKey: notificationKey) {
            notificationIds = NSKeyedUnarchiver.unarchiveObject(with: notifData) as! Set<String>
        }
        
        
        let label = "no_notif = \(notifArray.count)"
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.notifOpen, label: label)
        if(XAppDelegate.badge > 0){
            let retrieveLabel = "no_retrieved = \(XAppDelegate.badge)"
            XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.notifRetrieved, label: retrieveLabel)
        }
        UIApplication.shared.applicationIconBadgeNumber = 0
        XAppDelegate.badge = 0
        Utilities.updateNotificationBadge()
        let time = Date().timeIntervalSince1970 - XAppDelegate.lastGetAllNotificationsTs
        if(time > 60){
            self.getNotificationAndReloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateTimer.invalidate()
        updateTimer = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if(notifArray.count != 0 ){
            self.tableView.backgroundView = nil
            return 1
        } else {
            self.tableView.backgroundView = nil
            // Display a message when the table is empty
            let messageLabel = UILabel(frame:CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
            // This is created to calculate label position
            messageLabel.text = "You have no notifications yet"
            messageLabel.font = UIFont(name: "HelveticaNeue-Light", size:15)
            messageLabel.sizeToFit()
            let view = UIView(frame:CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            view.backgroundColor = UIColor.white
            // real label
            let fixedLabel = UILabel(frame:CGRect(x: (tableView.bounds.size.width - messageLabel.frame.width) / 2, y: (tableView.bounds.size.height - ADMOD_HEIGHT - messageLabel.frame.height) / 2, width: messageLabel.frame.width, height: messageLabel.frame.height))
            fixedLabel.textColor = UIColor.black
            fixedLabel.numberOfLines = 0
            fixedLabel.textAlignment = NSTextAlignment.center
            fixedLabel.font = messageLabel.font
            fixedLabel.text = messageLabel.text
            view.addSubview(fixedLabel)
            self.tableView.backgroundView = view
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notifArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : NotificationTableViewCell!
        cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell", for: indexPath) as! NotificationTableViewCell
        if let cell = cell {
            cell.resetUI()
            self.resetCornerRadius(cell)
        }
        cell.populateData(notifArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let id = notifArray[indexPath.row].notification_id
        if notificationIds.contains(id!) {
            cell.backgroundColor = UIColor.white
        } else {
            cell.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if let cell = cell {
            cell.backgroundColor = UIColor.white
            let id = notifArray[indexPath.row].notification_id
            notificationIds.insert(id!)
            let data = NSKeyedArchiver.archivedData(withRootObject: notificationIds)
            UserDefaults.standard.set(data, forKey: notificationKey)
            SocialManager.sharedInstance.clearNotificationWithId(id)
            let notifCell = cell as! NotificationTableViewCell
            let route = notifCell.notification.route
            if(route != nil && route != ""){
                let label = "notif_id = \(id) route = \(route)"
                XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.notifSelect, label: label)
//                print("didSelectRowAtIndexPath route == \(route)")
                DispatchQueue.main.async {
                    XAppDelegate.mobilePlatform.router.handleRoute(notifCell.notification.route);
                }
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    // MARK: Button actions
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        CacheManager.clearAllNotificationData()
        self.getNotificationAndReloadData()
        refreshControl.endRefreshing()
    }
    
    @IBAction func refreshButtonTapped(_ sender: AnyObject) {
        self.getNotificationAndReloadData()
    }
    
    @IBAction func clearAllTapped(_ sender: AnyObject) {
        
    }
    
    // MARK: Helpers
    func getNotificationAndReloadData(){
        
        if(notifArray.count == 0){ // first load
            Utilities.showHUD()
            tableView.backgroundColor = UIColor.white
        }
        XAppDelegate.socialManager.getAllNotification(0, completionHandler: { (result) -> Void in
            if let notifData = UserDefaults.standard.data(forKey: notificationKey) {
                self.notificationIds = NSKeyedUnarchiver.unarchiveObject(with: notifData) as! Set<String>
            }
            XAppDelegate.lastGetAllNotificationsTs = Date().timeIntervalSince1970
            DispatchQueue.main.async(execute: {
                Utilities.hideHUD()
                
                self.tableView.beginUpdates()
                let deltaCalculator = BKDeltaCalculator(equalityTest: { (notif1 , notif2) -> Bool in
                    let n1 = notif1 as! NotificationObject
                    let n2 = notif2 as! NotificationObject
                    return (n1.notification_id == n2.notification_id);
                })
                let delta = deltaCalculator.delta(fromOldArray: self.notifArray, toNewArray:result!)
                delta.applyUpdates(to: self.tableView,inSection:0,with:UITableViewRowAnimation.fade)
                self.notifArray = result!
                self.notifArray.sort(by: { $0.created > $1.created })
                self.tableView.endUpdates()
                
            })
        })
    }
    
    // MARK: UI Helper
    func getHeaderView() -> UIView {
        if let _ = tableHeaderView{
            
        } else {
            tableHeaderView = UIView()
            tableHeaderView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width,height: PADDING)
            tableHeaderView.backgroundColor = UIColor.clear
        }
        return tableHeaderView
    }
    
    func getFooterView() -> UIView {
        if let _ = tableFooterView{
            
        } else {
            tableFooterView = UIView()
            tableFooterView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: PADDING)
            tableFooterView.backgroundColor = UIColor.clear
            
        }
        return tableFooterView
    }
    
    // prevent corner radius from applying to middle rows
    func resetCornerRadius(_ cell : NotificationTableViewCell){
        DispatchQueue.main.async(execute: {
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
