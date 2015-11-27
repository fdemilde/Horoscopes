//
//  DiscoverViewController.swift
//  Horoscopes
//
//  Created by Binh Dang on 11/12/15.
//  Copyright © 2015 Binh Dang. All rights reserved.
//

import Foundation

class DiscoverViewController : ViewControllerWithAds, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var currentPage = 0
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        return refreshControl
    }()
    
    var isFollowed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBackground()
        setupInfiniteScroll()
        XAppDelegate.socialManager.getGlobalNewsfeed(0, isAddingData: false)
        self.tableView.pagingEnabled = true
        tableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "feedsFinishedLoading:", name: NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED, object: nil)
        tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func setupBackground(){
        let screenSize = Utilities.getScreenSize()
        let bgImageView = UIImageView(frame: CGRectMake(0,0,screenSize.width,screenSize.height))
        bgImageView.image = UIImage(named: "background")
        self.view.addSubview(bgImageView)
    }
    
    // MARK: Table datasource & delegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return XAppDelegate.dataStore.newsfeedGlobal.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.tableView.frame.height
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DiscoverTableCell", forIndexPath: indexPath) as! DiscoverTableCell
        let post = XAppDelegate.dataStore.newsfeedGlobal[indexPath.row]
        cell.parentViewController = self
        cell.setupCell(post)
        
        if let users = XAppDelegate.dataStore.usersFollowing {
            let userId = post.uid
            isFollowed = false
            for user in users {
                if user.uid == userId {
                    isFollowed = true
                    break
                }
            }
            cell.configureFollowButton(isFollowed)
            cell.followButton.addTarget(self, action: "followButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.followButton.tag = indexPath.row
        }
        
        return cell
    }
    
    // MARK: Notification Handlers
    
    func feedsFinishedLoading(notif : NSNotification){
        dispatch_async(dispatch_get_main_queue(),{
            Utilities.hideHUD()
            if(notif.object == nil){
                self.tableView.finishInfiniteScroll()
            } else {
                let newDataArray = notif.object as! [UserPost]
                self.insertRowsAtBottom(newDataArray)
            }
        })
    }
    
    // MARK: infinite scrolling support
    func insertRowsAtBottom(newData : [UserPost]){
        self.tableView.beginUpdates()
        let deltaCalculator = BKDeltaCalculator.defaultCalculator { (post1 , post2) -> Bool in
            let p1 = post1 as! UserPost
            let p2 = post2 as! UserPost
            return (p1.post_id == p2.post_id);
        }
        
        let delta = deltaCalculator.deltaFromOldArray(XAppDelegate.dataStore.newsfeedGlobal, toNewArray:newData)
        delta.applyUpdatesToTableView(self.tableView,inSection:0,withRowAnimation:UITableViewRowAnimation.Fade)
        XAppDelegate.dataStore.newsfeedGlobal = newData
        self.tableView.endUpdates()
        
        tableView.finishInfiniteScroll()
        
    }
    
    // MARK: Helpers
    
    func setupInfiniteScroll(){
        tableView.infiniteScrollIndicatorStyle = .White
        tableView.addInfiniteScrollWithHandler { (scrollView) -> Void in
            
            if(XAppDelegate.dataStore.isLastPage){
                self.tableView.finishInfiniteScroll()
                return
            } // last page dont need to request more
            self.currentPage++
            XAppDelegate.socialManager.getGlobalNewsfeed(self.currentPage, isAddingData: true)
        }
    }
    
    // MARK: Actions
    
    func followButtonTapped(sender: UIButton) {
        if let user = XAppDelegate.dataStore.newsfeedGlobal[sender.tag].user {
            if isFollowed {
                Utilities.showHUD()
                SocialManager.sharedInstance.unfollow(user, completionHandler: { (error) -> Void in
                    if let error = error {
                        Utilities.hideHUD()
                        Utilities.showError(error)
                    } else {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.tableView.reloadData()
                            Utilities.hideHUD()
                        })
                    }
                })
            } else {
                Utilities.showHUD()
                SocialManager.sharedInstance.follow(user, completionHandler: { (error) -> Void in
                    if let error = error {
                        Utilities.hideHUD()
                        Utilities.showError(error)
                    } else {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.tableView.reloadData()
                            Utilities.hideHUD()
                        })
                    }
                })
            }
        }
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        self.currentPage = 0
        XAppDelegate.socialManager.getGlobalNewsfeed(0, isAddingData: false, isRefreshing : true)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "feedsFinishedLoading:", name: NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED, object: nil)
        
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
}
