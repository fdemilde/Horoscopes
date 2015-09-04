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
    var startPositionY = 0 as CGFloat
    var notifArray = [NotificationObject]()
    var router : Router!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        router = XAppDelegate.mobilePlatform.router
        setupRouter()
        
        var image = Utilities.getImageToSupportSize("background", size: self.view.frame.size, frame: self.view.bounds)
        self.view.backgroundColor = UIColor(patternImage: image)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.layer.cornerRadius = 5
        tableView.layer.masksToBounds = true
        
//        self.unfollowTest()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.getNotificationAndReloadData()
    }
    
    func unfollowTest(){
        XAppDelegate.socialManager.unfollow(11, completionHandler: { (error) -> Void in
            
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell : NotificationTableViewCell!
        cell = tableView.dequeueReusableCellWithIdentifier("NotificationTableViewCell", forIndexPath: indexPath) as! NotificationTableViewCell
        cell.populateData(notifArray[indexPath.row])
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell = tableView.cellForRowAtIndexPath(indexPath)
        if let cell = cell {
            var notifCell = cell as! NotificationTableViewCell
            var route = notifCell.notification.route
            if(route != nil && route != ""){
                XAppDelegate.mobilePlatform.router.handleRoute(notifCell.notification.route);
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
        XAppDelegate.socialManager.getAllNotification(0, completionHandler: { (result) -> Void in
            dispatch_async(dispatch_get_main_queue(),{
                self.notifArray = result!
                self.tableView.reloadData()
            })
        })
    }
    
    // MARK: Router handler
    
    func setupRouter(){
        router.addRoute("/today/:id/:post_id/*info", blockCode: { (param) -> Void in
            println("Route == today param dict = \(param)")
        })
        
        router.addRoute("/today/fortunecookie", blockCode: { (param) -> Void in
            println("Route == fortunecookie param dict = \(param)")
        })
        
        router.addRoute("/archive", blockCode: { (param) -> Void in
            println("Route == archive param dict = \(param)")
        })
        
        router.addRoute("/archive/:date/:sign", blockCode: { (param) -> Void in
            println("Route == archive param dict = \(param)")
        })
        
        router.addRoute("/feed/global", blockCode: { (param) -> Void in
            println("Route == global param dict = \(param)")
        })
        
        router.addRoute("/feed/following", blockCode: { (param) -> Void in
            println("Route == feed following param dict = \(param)")
        })
        
        router.addRoute("/profile/:uid/feed", blockCode: { (param) -> Void in
            println("Route == feed param dict = \(param)")
            let uid = param["uid"] as! String
            SocialManager.sharedInstance.getProfile(uid, completionHandler: { (result, error) -> Void in
                if let error = error {
                    
                } else {
                    let userProfile = result![0]
                    let controller = self.storyboard?.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
                    controller.profileType = ProfileType.OtherUser
                    controller.userProfile = userProfile
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.navigationController?.pushViewController(controller, animated: true)
                    })
                }
            })
        })
        
        router.addRoute("/profile/:uid/followers", blockCode: { (param) -> Void in
            println("Route == followers param dict = \(param)")
        })
        
        router.addRoute("/profile/:uid/following", blockCode: { (param) -> Void in
            println("Route == following param dict = \(param)")
        })
        
        router.addRoute("/profile/me", blockCode: { (param) -> Void in
            println("Route == profile me param dict = \(param)")
        })
        
        router.addRoute("/profile/me/setsign", blockCode: { (param) -> Void in
            println("Route == profile me setsign param dict = \(param)")
        })
        
        router.addRoute("/profile/me/findfriends", blockCode: { (param) -> Void in
            println("Route == profile findfriends param dict = \(param)")
        })
        
        router.addRoute("/post/:post_id", blockCode: { (param) -> Void in
            println("Route == post with param dict = \(param)")
        })
        
        router.addRoute("/post/:post_id/hearts", blockCode: { (param) -> Void in
            if let postId = param["post_id"] as? String{
                XAppDelegate.socialManager.getPost(postId, completionHandler: { (result, error) -> Void in
                    if let error = error {
                        
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
            println("Route == settings with param dict = \(param)")
        })
    }
}
