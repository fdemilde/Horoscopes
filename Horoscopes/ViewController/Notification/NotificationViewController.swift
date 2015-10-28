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
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        return refreshControl
        }()
    
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
        self.getNotificationAndReloadData()
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
            messageLabel.text = "There is no notification"
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
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifArray.count
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if let cell = cell {
            let notifCell = cell as! NotificationTableViewCell
            let route = notifCell.notification.route
            if(route != nil && route != ""){
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
        // TODO: update the data source
//        print("Updating its data source...")
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
        if(notifArray.count == 0){ // first load
            Utilities.showHUD()
            tableView.backgroundColor = UIColor.whiteColor()
        }
        
        XAppDelegate.socialManager.getAllNotification(0, completionHandler: { (result) -> Void in
            dispatch_async(dispatch_get_main_queue(),{
                Utilities.hideHUD()
                self.notifArray = result!
                // remove all notification 
//                XAppDelegate.socialManager.clearAllNotification(self.notifArray)
                self.notifArray.sortInPlace({ $0.created > $1.created })
                self.tableView.reloadData()
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
    func resetCornerRadius(cell : NotificationTableViewCell) -> NotificationTableViewCell{
        
        return Utilities.makeCornerRadius(cell, maskFrame: cell.bounds, roundOptions: UIRectCorner(), radius: 4.0) as! NotificationTableViewCell
    }
}
