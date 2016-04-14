//
//  AlternateCommunityViewController.swift
//  Horoscopes
//
//  Created by Binh Dang on 12/3/15.
//  Copyright © 2015 Binh Dang. All rights reserved.
//

import Foundation
class AlternateCommunityViewController: ViewControllerWithAds, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate {
    
    let ADD_BUTTON_SIZE: CGFloat = 40
    let POST_BUTTON_SIZE = CGSizeMake(100, 90)
    
    @IBOutlet weak var tableView: UITableView!
    var currentPage = 0
    
    @IBOutlet weak var overlay: UIView!
    
    var lastContentOffsetY = 0 as CGFloat
    var bgImageView : UIImageView!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBackground()
        self.tableView.pagingEnabled = true
        tableView.addSubview(refreshControl)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.commOpen, label: nil)
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AlternateCommunityViewController.handleScrollToTop(_:)), name: NOTIFICATION_TABLE_VIEW_SCROLL_TO_TOP, object: nil)
        
        // if page 0 cache expire, reset page number = 0
        if isFirstPageExpired() {
            currentPage = 0
        }
        XAppDelegate.socialManager.getGlobalNewsfeed(currentPage, isAddingData: false)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AlternateCommunityViewController.feedsFinishedLoading(_:)), name: NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED, object: nil)
        if let bgImageView = self.bgImageView{
            self.view.sendSubviewToBack(bgImageView)
        }
        checkAndAddWelcomeView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillLayoutSubviews() {
        
    }
    
    func setupBackground(){
        let screenSize = Utilities.getScreenSize()
        bgImageView = UIImageView(frame: CGRectMake(0,0,screenSize.width,screenSize.height))
        bgImageView.image = UIImage(named: "background")
        self.view.addSubview(bgImageView)
        self.view.sendSubviewToBack(bgImageView)
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
        let cell = tableView.dequeueReusableCellWithIdentifier("DiscoverTableCell", forIndexPath: indexPath) as! PostTableViewCell
        let post = XAppDelegate.dataStore.newsfeedGlobal[indexPath.row]
        cell.viewController = self
        cell.configureCellForNewsfeed(post)
        if(indexPath.row == XAppDelegate.dataStore.newsfeedGlobal.count-1){ // last row
            loadDataForNextPage()
        }
        return cell
    }
    
    // MARK: Scrollview delegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        var trackerLabel = "up = "
        if (self.lastContentOffsetY > scrollView.contentOffset.y) {
            trackerLabel += "1"
        } else {
            trackerLabel += "0"
        }
        
        self.lastContentOffsetY = scrollView.contentOffset.y
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.commSwipe, label: trackerLabel)
    }
    
    // MARK: Notification Handlers
    
    func feedsFinishedLoading(notif : NSNotification){
        dispatch_async(dispatch_get_main_queue(),{
            Utilities.hideHUD()
            if(notif.object == nil){
                self.tableView.finishInfiniteScroll()
            } else {
                let newDataArray = notif.object as! [UserPost]
                    XAppDelegate.dataStore.newsfeedGlobal = newDataArray
                    self.tableView.reloadData()
            }
        })
    }
    
    func handleScrollToTop(notif : NSNotification){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_TABLE_VIEW_SCROLL_TO_TOP, object: nil)
        tableView.setContentOffset(CGPointZero, animated: false)
    }
    
    // MARK: infinite scrolling support
    func insertRowsAtBottom(newData : [UserPost]){
        self.tableView.beginUpdates()
        let deltaCalculator = BKDeltaCalculator(equalityTest: { (post1 , post2) -> Bool in
            let p1 = post1 as! UserPost
            let p2 = post2 as! UserPost
            return (p1.post_id == p2.post_id);
        })
        
        let delta = deltaCalculator.deltaFromOldArray(XAppDelegate.dataStore.newsfeedGlobal, toNewArray:newData)
        delta.applyUpdatesToTableView(self.tableView,inSection:0,withRowAnimation:UITableViewRowAnimation.Middle)
        XAppDelegate.dataStore.newsfeedGlobal = newData
        self.tableView.endUpdates()
        if let indexes = tableView.indexPathsForVisibleRows {
            let targetRow = indexes[indexes.count - 1].row
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: targetRow, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        }
    }
    
    // MARK: Helpers
    
    func setupInfiniteScroll(){
        tableView.infiniteScrollIndicatorStyle = .White
        tableView.addInfiniteScrollWithHandler { (scrollView) -> Void in
            
            if(XAppDelegate.dataStore.isLastPage){
                self.tableView.finishInfiniteScroll()
                return
            } // last page dont need to request more
            let label = "page = \(self.currentPage)"
            XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.commLoadmore, label: label)
            self.tableView.finishInfiniteScroll()
        }
    }
    
    func loadDataForNextPage(){
        if(XAppDelegate.dataStore.isLastPage){
            return
        }
        self.currentPage += 1
        let label = "page = \(self.currentPage)"
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.commLoadmore, label: label)
        XAppDelegate.socialManager.getGlobalNewsfeed(self.currentPage, isAddingData: true)
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.commReload, label: nil)
        self.currentPage = 0
        XAppDelegate.socialManager.getGlobalNewsfeed(0, isAddingData: false, isRefreshing : true)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AlternateCommunityViewController.feedsFinishedLoading(_:)), name: NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED, object: nil)
        
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    // func check page 0 cache
    
    func isFirstPageExpired() -> Bool {
        let postData = NSMutableDictionary()
        let pageString = String(format:"%d", 0)
        postData.setObject(pageString, forKey: "page")
        if(CacheManager.isCacheExpired(GET_GLOBAL_FEED, postData: postData)){
            return true
        } else {
            return false
        }

    }
    
    func scrollToTop() {
        tableView.setContentOffset(CGPointZero, animated: true)
    }
    
    // MARK: Welcomeview
    func checkAndAddWelcomeView() {
        // if first time go to Community page, show welcome
        let haveShownWelcome = NSUserDefaults.standardUserDefaults().boolForKey(HAVE_SHOWN_WELCOME_SCREEN)
        if(haveShownWelcome){
            return
        }
        
        // Open community welcome view here
        if(XAppDelegate.window!.rootViewController!.isKindOfClass(UITabBarController)){
            let rootVC = XAppDelegate.window!.rootViewController! as? CustomTabBarController
            // setup community welcome view here
            let communityWelcomeView = CommunityWelcomeView(frame: CGRectMake(0, 0, Utilities.getScreenSize().width, Utilities.getScreenSize().height))
            communityWelcomeView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
            rootVC!.view.addSubview(communityWelcomeView)
            rootVC!.view.bringSubviewToFront(communityWelcomeView)
        }
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: HAVE_SHOWN_WELCOME_SCREEN)
    }
}