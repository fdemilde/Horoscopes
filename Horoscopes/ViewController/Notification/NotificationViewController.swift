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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        router = XAppDelegate.mobilePlatform.router
        setupRouter()
        
        let image = Utilities.getImageToSupportSize("background", size: self.view.frame.size, frame: self.view.bounds)
        self.view.backgroundColor = UIColor(patternImage: image)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 4
        tableView.clipsToBounds = true
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
    
    @IBAction func refreshButtonTapped(sender: AnyObject) {
        self.getNotificationAndReloadData()
    }
    
    @IBAction func clearAllTapped(sender: AnyObject) {
        XAppDelegate.socialManager.clearAllNotification()
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
                self.notifArray.sortInPlace({ $0.created > $1.created })
                self.tableView.reloadData()
            })
        })
    }
    
    // MARK: Router handler
    
    func setupRouter(){
        router.addRoute("/today/:id/:post_id/*info", blockCode: { (param) -> Void in
            print("Route == today param dict = \(param)")
        })
        
        router.addRoute("/today/fortunecookie", blockCode: { (param) -> Void in
            print("Route == fortunecookie param dict = \(param)")
        })
        
        router.addRoute("/archive", blockCode: { (param) -> Void in
            print("Route == archive param dict = \(param)")
        })
        
        router.addRoute("/archive/:date/:sign", blockCode: { (param) -> Void in
            print("Route == archive param dict = \(param)")
        })
        
        router.addRoute("/feed/global", blockCode: { (param) -> Void in
            print("Route == global param dict = \(param)")
        })
        
        router.addRoute("/feed/following", blockCode: { (param) -> Void in
            print("Route == feed following param dict = \(param)")
        })
        
        router.addRoute("/profile/:uid/feed", blockCode: { (param) -> Void in
            print("Route == feed param dict = \(param)")
            let uid = param["uid"] as! String
            Utilities.showHUD()
            SocialManager.sharedInstance.getProfile(uid, completionHandler: { (result, error) -> Void in
                Utilities.hideHUD()
                if let _ = error {
                    
                } else {
                    let userProfile = result![0]
                    let controller = self.storyboard?.instantiateViewControllerWithIdentifier("OtherProfileViewController") as! OtherProfileViewController
                    controller.userProfile = userProfile
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.navigationController?.pushViewController(controller, animated: true)
                    })
                }
            })
        })
        
        router.addRoute("/profile/:uid/followers", blockCode: { (param) -> Void in
            print("Route == followers param dict = \(param)")
        })
        
        router.addRoute("/profile/:uid/following", blockCode: { (param) -> Void in
            print("Route == following param dict = \(param)")
        })
        
        router.addRoute("/profile/me", blockCode: { (param) -> Void in
            print("Route == profile me param dict = \(param)")
        })
        
        router.addRoute("/profile/me/setsign", blockCode: { (param) -> Void in
            print("Route == profile me setsign param dict = \(param)")
        })
        
        router.addRoute("/profile/me/findfriends", blockCode: { (param) -> Void in
            print("Route == profile findfriends param dict = \(param)")
        })
        
        router.addRoute("/post/:post_id", blockCode: { (param) -> Void in
            print("Route == post with param dict = \(param)")
        })
        
        router.addRoute("/post/:post_id/hearts", blockCode: { (param) -> Void in
            if let postId = param["post_id"] as? String{
                Utilities.showHUD()
                XAppDelegate.socialManager.getPost(postId, completionHandler: { (result, error) -> Void in
                    Utilities.hideHUD()
                    if let _ = error {
                        
                    } else {
                        if let result = result {
                        for post : UserPost in result {
                            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("SinglePostViewController") as! SinglePostViewController
                            controller.userPost = post
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.navigationController?.pushViewController(controller, animated: true)
                                })
                            }
                        }
                    }
                })
            }
        })
        
        router.addRoute("/settings", blockCode: { (param) -> Void in
            print("Route == settings with param dict = \(param)")
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
