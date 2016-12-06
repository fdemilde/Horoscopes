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
    let POST_BUTTON_SIZE = CGSize(width: 100, height: 90)
    
    @IBOutlet weak var tableView: UITableView!
    var currentPage = 0
    
    @IBOutlet weak var overlay: UIView!
    
    var lastContentOffsetY = 0 as CGFloat
    var bgImageView : UIImageView!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(AlternateCommunityViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBackground()
        self.tableView.isPagingEnabled = true
        tableView.addSubview(refreshControl)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.commOpen, label: nil)
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(AlternateCommunityViewController.handleScrollToTop(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_TABLE_VIEW_SCROLL_TO_TOP), object: nil)
        
        // if page 0 cache expire, reset page number = 0
        if isFirstPageExpired() {
            currentPage = 0
        }
        XAppDelegate.socialManager.getGlobalNewsfeed(currentPage, isAddingData: false)
        NotificationCenter.default.addObserver(self, selector: #selector(AlternateCommunityViewController.feedsFinishedLoading(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED), object: nil)
        if let bgImageView = self.bgImageView{
            self.view.sendSubview(toBack: bgImageView)
        }
        checkAndAddWelcomeView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillLayoutSubviews() {
        
    }
    
    func setupBackground(){
        let screenSize = Utilities.getScreenSize()
        bgImageView = UIImageView(frame: CGRect(x: 0,y: 0,width: screenSize.width,height: screenSize.height))
        bgImageView.image = UIImage(named: "background")
        self.view.addSubview(bgImageView)
        self.view.sendSubview(toBack: bgImageView)
    }
    
    // MARK: Table datasource & delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return XAppDelegate.dataStore.newsfeedGlobal.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView.frame.height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiscoverTableCell", for: indexPath) as! PostTableViewCell
        let post = XAppDelegate.dataStore.newsfeedGlobal[indexPath.row]
        cell.viewController = self
        cell.configureCellForNewsfeed(post)
        if(indexPath.row == XAppDelegate.dataStore.newsfeedGlobal.count-1){ // last row
            loadDataForNextPage()
        }
        return cell
    }
    
    // MARK: Scrollview delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
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
    
    func feedsFinishedLoading(_ notif : Notification){
        DispatchQueue.main.async(execute: {
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
    
    func handleScrollToTop(_ notif : Notification){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NOTIFICATION_TABLE_VIEW_SCROLL_TO_TOP), object: nil)
        tableView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    // MARK: infinite scrolling support
    func insertRowsAtBottom(_ newData : [UserPost]){
        self.tableView.beginUpdates()
        let deltaCalculator = BKDeltaCalculator(equalityTest: { (post1 , post2) -> Bool in
            let p1 = post1 as! UserPost
            let p2 = post2 as! UserPost
            return (p1.post_id == p2.post_id);
        })
        
        let delta = deltaCalculator?.delta(fromOldArray: XAppDelegate.dataStore.newsfeedGlobal, toNewArray:newData)
        delta?.applyUpdates(to: self.tableView,inSection:0,with:UITableViewRowAnimation.middle)
        XAppDelegate.dataStore.newsfeedGlobal = newData
        self.tableView.endUpdates()
        if let indexes = tableView.indexPathsForVisibleRows {
            let targetRow = indexes[indexes.count - 1].row
            tableView.scrollToRow(at: IndexPath(row: targetRow, section: 0), at: UITableViewScrollPosition.top, animated: true)
        }
    }
    
    // MARK: Helpers
    
    func setupInfiniteScroll(){
        tableView.infiniteScrollIndicatorStyle = .white
        tableView.addInfiniteScroll { (scrollView) -> Void in
            
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
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.commReload, label: nil)
        self.currentPage = 0
        XAppDelegate.socialManager.getGlobalNewsfeed(0, isAddingData: false, isRefreshing : true)
        NotificationCenter.default.addObserver(self, selector: #selector(AlternateCommunityViewController.feedsFinishedLoading(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED), object: nil)
        
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    // func check page 0 cache
    
    func isFirstPageExpired() -> Bool {
        let postData = NSMutableDictionary()
        let pageString = String(format:"%d", 0)
        postData.setObject(pageString, forKey: "page" as NSCopying)
        if(CacheManager.isCacheExpired(GET_GLOBAL_FEED, postData: postData)){
            return true
        } else {
            return false
        }

    }
    
    func scrollToTop() {
        tableView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    // MARK: Welcomeview
    func checkAndAddWelcomeView() {
        // if first time go to Community page, show welcome
        let haveShownWelcome = UserDefaults.standard.bool(forKey: HAVE_SHOWN_WELCOME_SCREEN)
        if(haveShownWelcome){
            return
        }
        
        // Open community welcome view here
        if(XAppDelegate.window!.rootViewController!.isKind(of: UITabBarController.self)){
            let rootVC = XAppDelegate.window!.rootViewController! as? CustomTabBarController
            // setup community welcome view here
            let communityWelcomeView = CommunityWelcomeView(frame: CGRect(x: 0, y: 0, width: Utilities.getScreenSize().width, height: Utilities.getScreenSize().height))
            communityWelcomeView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
            rootVC!.view.addSubview(communityWelcomeView)
            rootVC!.view.bringSubview(toFront: communityWelcomeView)
        }
        UserDefaults.standard.set(true, forKey: HAVE_SHOWN_WELCOME_SCREEN)
    }
    
    
}
