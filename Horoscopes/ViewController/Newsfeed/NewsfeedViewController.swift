//
//  NewsfeedViewController.swift
//  Horoscopes
//
//  Created by Dang Doan on 8/21/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

class NewsfeedViewController: ViewControllerWithAds, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate {

    let NEWFEEDS_POST_FEEL_IMG_NAME = "newfeeds_post_feel"
    let NEWFEEDS_POST_FEEL_TEXT = "How do you feel today?"
    
    let NEWFEEDS_POST_STORY_IMG_NAME = "newfeeds_post_story"
    let NEWFEEDS_POST_STORY_TEXT = "Share your story"
    
    let NEWFEEDS_POST_MIND_IMG_NAME = "newfeeds_post_mind"
    let NEWFEEDS_POST_MIND_TEXT = "What’s on your mind?"
    
    let postTypes = [
        ["How do you feel today?", "post_type_feel", "feeling"],
        ["Share a story", "post_type_story", "story"],
        ["What's on your mind?", "post_type_mind", "onyourmind"]
        
    ]
    
    let defaultEstimatedRowHeight: CGFloat = 400
    let ADD_BUTTON_SIZE: CGFloat = 40
    let FB_BUTTON_SIZE = 80 as CGFloat
    let POST_BUTTON_SIZE = CGSizeMake(100, 90)
    var addButton: UIButton!
    let PADDING = 20 as CGFloat
    let HEADER_HEIGHT: CGFloat = 130 as CGFloat
    let FOOTER_HEIGHT: CGFloat = 80 as CGFloat
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var globalButton: UIButton!
    @IBOutlet weak var followingButton: UIButton!
    var postButtonsView: PostButtonsView!
    
//    var userPostArray = [UserPost]()
    var tabType = NewsfeedTabType.Following
    var currentSelectedSign = 0 // 0 is all
    var currentPage = 0
    var overlay : UIView!
//    var oldNewsfeedArray = [UserPost]()
    
    @IBOutlet weak var tabView: UIView!
    var tableHeaderView: NewsfeedTableHeaderView!
    let textviewForCalculating = UITextView()
    
    
    struct TableViewConstants {
        static let defaultTableViewCellIdentifier = "defaultCell"
        static let postTableViewCellIdentifier = "postCell"
    }
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
//        self.resetTapButtonColor()
        self.setupInfiniteScroll()
        tableHeaderView = NewsfeedTableHeaderView(frame: CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.frame.width, height: 40))
        tableHeaderView.setupDate(NSDate())
        tableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // remove all observer first
        NSNotificationCenter.defaultCenter().removeObserver(self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "feedsFinishedLoading:", name: NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "feedsFinishedLoading:", name: NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateFollowingStatusFinished:", name: NOTIFICATION_UPDATE_FOLLOWING_STATUS_FINISHED, object: nil)
        if SocialManager.sharedInstance.isLoggedInFacebook() && SocialManager.sharedInstance.isLoggedInZwigglers() {
            Utilities.getImageFromUrlString(XAppDelegate.currentUser.imgURL, completionHandler: { (image) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    self.tableHeaderView.profileImageView.image = image
                })
            })
        } else {
//            self.tableHeaderView.profileImageView.image = UIImage(named: "default_avatar")
        }

        if(tabType == NewsfeedTabType.Following && XAppDelegate.dataStore.newsfeedFollowing.count == 0){ // only check if no data for following yet
            tableView.reloadData()
            if(XAppDelegate.socialManager.isLoggedInFacebook()){ // user already logged in facebook
                dispatch_async(dispatch_get_main_queue(),{
                    self.checkAndLoginZwigglers()
                })
            }
            
        }
        
        tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Setup View
    func setupView(){
        // Do any additional setup after loading the view.
        let backgroundImage = Utilities.getImageToSupportSize("background", size: view.frame.size, frame: view.bounds)
        view.backgroundColor = UIColor(patternImage: backgroundImage)
        tableView?.estimatedRowHeight = defaultEstimatedRowHeight
        tableView?.rowHeight = UITableViewAutomaticDimension
        self.setupAddPostButton()
        // create tabView shadow
        tabView?.layer.shadowOffset = CGSize(width: 0, height: 1)
        tabView?.layer.shadowOpacity = 0.2
        tabView?.layer.shadowRadius = 1
    }
    
    func setupAddPostButton() {
        addButton = UIButton(frame: CGRectMake(view.frame.width - ADD_BUTTON_SIZE - 10, view.frame.height - ADD_BUTTON_SIZE - TABBAR_HEIGHT - 10, ADD_BUTTON_SIZE, ADD_BUTTON_SIZE))
        addButton.addTarget(self, action: "postButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        addButton.setImage(UIImage(named: "newsfeed_add_btn"), forState: .Normal)
        
        // setup overlay
        overlay = UIView(frame: CGRectMake(0, 0, Utilities.getScreenSize().width, Utilities.getScreenSize().height))
        overlay.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        overlay.alpha = 0
        
        view.addSubview(overlay)
        view.bringSubviewToFront(overlay)
        
        let overlayTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "overlayTapGestureRecognizer:")
        overlay.addGestureRecognizer(overlayTapGestureRecognizer)
        postButtonsView = PostButtonsView(frame: overlay.frame)
        postButtonsView.setTextColor(UIColor.whiteColor())
        postButtonsView.hostViewController = self
        overlay.addSubview(postButtonsView)
        
        view.addSubview(addButton)
        view.bringSubviewToFront(addButton)
    }
    
    // MARK: Post buttons handlers
    func postButtonTapped(){
        if(self.overlay.alpha == 1.0){
            overlayFadeout()
        } else {
            overlayFadeIn()
        }
        
        
    }
    
    func overlayTapGestureRecognizer(recognizer: UITapGestureRecognizer){
        overlayFadeout()
    }
    
    func overlayFadeIn(){
        UIView.animateWithDuration(0.2, animations: {
            self.overlay.alpha = 1.0
        })
    }
    
    func overlayFadeout(){
        UIView.animateWithDuration(0.2, animations: {
            self.overlay.alpha = 0
        })
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
    
    func updateFollowingStatusFinished(notif : NSNotification) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
    }
    
    // MARK: Actions
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        self.currentPage = 0
        if(self.tabType == NewsfeedTabType.Global){
            XAppDelegate.socialManager.getGlobalNewsfeed(0, isAddingData: false, isRefreshing : true)
        } else {
            XAppDelegate.socialManager.getFollowingNewsfeed(0, isAddingData: false)
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "feedsFinishedLoading:", name: NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED, object: nil)
        
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    @IBAction func globalBtnTapped(sender: AnyObject) {
//        oldNewsfeedArray = XAppDelegate.dataStore.newsfeedGlobal
//        self.scrollToTop()
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED, object: nil)
        currentPage = 0
        tableView.finishInfiniteScroll()
        XAppDelegate.dataStore.resetPage()
        if(self.tabType != NewsfeedTabType.Global){
            self.tabType = NewsfeedTabType.Global
            tableView.reloadData()
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "feedsFinishedLoading:", name: NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED, object: nil)
        XAppDelegate.socialManager.getGlobalNewsfeed(0, isAddingData: false)
    }
    
    @IBAction func followingButtonTapped(sender: AnyObject) {
//        oldNewsfeedArray = XAppDelegate.dataStore.newsfeedFollowing
//        self.scrollToTop()
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED,object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED, object: nil)
        // when button is tapped, we load data again
        currentPage = 0
        tableView.finishInfiniteScroll()
        XAppDelegate.dataStore.resetPage()
        if(self.tabType != NewsfeedTabType.Following){
            self.tabType = NewsfeedTabType.Following
            if(XAppDelegate.socialManager.isLoggedInFacebook()){
                tableView.reloadData()
                
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "feedsFinishedLoading:", name: NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED, object: nil)
                XAppDelegate.socialManager.getFollowingNewsfeed(0, isAddingData: false)
            } else {
//                userPostArray.removeAll(keepCapacity: false)
                self.tableView.reloadData()
            }
        } else {
            if(XAppDelegate.socialManager.isLoggedInFacebook()){
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "feedsFinishedLoading:", name: NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED, object: nil)
                XAppDelegate.socialManager.getFollowingNewsfeed(0, isAddingData: false)
            } else {
                tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source and delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getTotalRowsInTable()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if(!XAppDelegate.socialManager.isLoggedInFacebook()){
            // if Following tab and not logged in, show log in view
            if(self.tabType == NewsfeedTabType.Following){
                let bg = self.createEmptyTableHeaderBackground()
                let facebookButton = UIButton()
                facebookButton.frame = CGRectMake((tableView.bounds.width - FB_BUTTON_SIZE)/2, (tableView.bounds.height - FB_BUTTON_SIZE)/2 - 40, FB_BUTTON_SIZE, FB_BUTTON_SIZE)
                facebookButton.addTarget(self, action: "facebookLogin:", forControlEvents: UIControlEvents.TouchUpInside)
                facebookButton.setImage(UIImage(named: "fb_login_icon"), forState: UIControlState.Normal)
                bg.addSubview(facebookButton)
                let label = UILabel()
                label.text = "Login Facebook to follow your friends"
                label.sizeToFit()
                label.frame = CGRectMake((tableView.bounds.width - label.frame.size.width)/2, facebookButton.frame.origin.y + facebookButton.frame.height + 25, label.frame.size.width, label.frame.size.height) // 15 is padding b/w button and label
                bg.addSubview(label)
                tableView.tableHeaderView = bg
                return 1
            }
        }
        
        if(getFeedArray().count == 0){
            tableView.tableHeaderView = createEmptyTableHeaderBackgroundWithMessage()
        } else {
            tableView.tableHeaderView = tableHeaderView
        }
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewConstants.postTableViewCellIdentifier, forIndexPath: indexPath) as! PostTableViewCell
        let post = getFeedDataForRow(indexPath.row)
        cell.configureCellForNewsfeed(post)
        cell.viewController = self
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? PostTableViewCell {
            let post = getFeedDataForRow(indexPath.row)
            cell.configureNewsfeedUi()
            if post.user?.sign >= 0 {
                cell.changeHoroscopeSignViewWidthToDefault()
            } else {
                cell.changeHoroscopeSignViewWidthToZero()
            }
            if NSUserDefaults.standardUserDefaults().boolForKey(String(post.post_id)) {
                cell.likeButton.userInteractionEnabled = false
            } else {
                cell.likeButton.userInteractionEnabled = true
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post = getFeedDataForRow(indexPath.row)
        return getAboutCellHeight(post.message)
    }
    
    // MARK: - Delegate
    // Networks
    func checkAndLoginZwigglers(){
        
        if !SocialManager.sharedInstance.isLoggedInZwigglers(){
            
            XAppDelegate.socialManager.loginZwigglers(FBSDKAccessToken .currentAccessToken().tokenString, completionHandler: { (result, error) -> Void in
                if(error != nil){
                    Utilities.showAlertView(self, title: "Error occured", message: "Try again later")
                } else {
                    self.getFollowingUser()
                    XAppDelegate.socialManager.getFollowingNewsfeed(0, isAddingData: false)
                    
                }
            })
        } else {
            self.getFollowingUser()
            XAppDelegate.socialManager.getFollowingNewsfeed(0, isAddingData: false)
        }
        
    }
    
    // MARK: facebook
    func facebookLogin(sender: UIButton!) {
        Utilities.showHUD()
        XAppDelegate.socialManager.login(self) { (error, permissionGranted) -> Void in
            Utilities.hideHUD()
            if(error != nil){
                Utilities.showAlertView(self, title: "Error occured", message: "Try again later")
                return
            } else {
                if(permissionGranted == false){
                    Utilities.showAlertView(self, title: "Permission denied", message: "Please check your permission again")
                    return
                } else {
                    
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: "feedsFinishedLoading:", name: NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED, object: nil)
                    dispatch_async(dispatch_get_main_queue(),{
                        self.getFollowingUser()
                        XAppDelegate.socialManager.getFollowingNewsfeed(0, isAddingData: false)
                    })
                }
            }
        }
    }
    
    // MARK: Helpers
    
    func setupInfiniteScroll(){
        tableView.infiniteScrollIndicatorStyle = .White
        tableView.addInfiniteScrollWithHandler { (scrollView) -> Void in
            if(!XAppDelegate.socialManager.isLoggedInFacebook() && self.tabType == NewsfeedTabType.Following){
                self.tableView.finishInfiniteScroll()
                return
            }
            
            if(XAppDelegate.dataStore.isLastPage){
                self.tableView.finishInfiniteScroll()
                return
            } // last page dont need to request more
            self.currentPage++
            
            if(self.tabType == NewsfeedTabType.Following){
//                self.oldNewsfeedArray = XAppDelegate.dataStore.newsfeedFollowing
                XAppDelegate.socialManager.getFollowingNewsfeed(self.currentPage, isAddingData: true)
            } else {
//                self.oldNewsfeedArray = XAppDelegate.dataStore.newsfeedGlobal
                XAppDelegate.socialManager.getGlobalNewsfeed(self.currentPage, isAddingData: true)
            }
        }
    }
    
    // if no feed to show or user doesn't log in, show white background
    func createEmptyTableHeaderBackground() -> UIView{
        let bg = UIView(frame: self.tableView.bounds)
        bg.layer.cornerRadius = 5
        bg.backgroundColor = UIColor.whiteColor()
        bg.userInteractionEnabled = true
        return bg
    }
    
    func createEmptyTableHeaderBackgroundWithMessage() -> UIView{
        let bg = self.createEmptyTableHeaderBackground()
        let label = UILabel()
        label.text = "No feeds available"
        label.font = UIFont(name: "HelveticaNeue-Light", size:15)
        label.sizeToFit()
        label.frame = CGRectMake((tableView.bounds.width - label.frame.size.width)/2, (tableView.bounds.height - label.frame.size.height)/2, label.frame.size.width, label.frame.size.height)
        bg.addSubview(label)
        return bg
    }
    
    func scrollToTop(){
        tableView.setContentOffset(CGPointZero, animated:true)
    }
    
    func getFollowingUser(){
        if(DataStore.sharedInstance.usersFollowing != nil){
            return
        }
        SocialManager.sharedInstance.getProfilesOfUsersFollowing { (result, error) -> Void in
            if let error = error {
                Utilities.showError(error, viewController: self)
            } else {
                DataStore.sharedInstance.usersFollowing = result!
                DataStore.sharedInstance.updateFollowingStatus(.Both)
            }
            
        }
    }
    
    // MARK: Table Cell Helpers
    
    func getAboutCellHeight(text : String) -> CGFloat {
        let font = UIFont(name: "Book Antiqua", size: 15)
        let attrs = NSDictionary(object: font!, forKey: NSFontAttributeName)
        let string = NSMutableAttributedString(string: text, attributes: attrs as? [String : AnyObject])
        let textViewWidth = Utilities.getScreenSize().width - (PADDING * 2)
        let textViewHeight = self.calculateTextViewHeight(string, width: textViewWidth)
        return textViewHeight + HEADER_HEIGHT + FOOTER_HEIGHT + PADDING * 3
    }
    
    func calculateTextViewHeight(string: NSAttributedString, width: CGFloat) ->CGFloat {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        let att = string.mutableCopy() as! NSMutableAttributedString
        att.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, att.string.characters.count))
        
        textviewForCalculating.attributedText = att
        let size = textviewForCalculating.sizeThatFits(CGSizeMake(width, CGFloat.max))
        let height = ceil(size.height)
        return height
    }
    
    // MARK: Table Data helpers
    
    func getTotalRowsInTable() -> Int{
        var result = 0 // default 1 row for "What's on your mind" cell
        if(tabType == NewsfeedTabType.Global){
             result += XAppDelegate.dataStore.newsfeedGlobal.count
        } else {
             result += XAppDelegate.dataStore.newsfeedFollowing.count
        }
        return result
    }
    
    func getFeedDataForRow(row : Int) -> UserPost {
        if(tabType == NewsfeedTabType.Global){
            return XAppDelegate.dataStore.newsfeedGlobal[row]
        } else {
            return XAppDelegate.dataStore.newsfeedFollowing[row]
        }
    }
    
    func getFeedArray() -> [UserPost]{
        if(tabType == NewsfeedTabType.Global){
            return XAppDelegate.dataStore.newsfeedGlobal
        } else {
            return XAppDelegate.dataStore.newsfeedFollowing
        }
    }
    
    // MARK: infinite scrolling support 
    func insertRowsAtBottom(newData : [UserPost]){
        self.tableView.beginUpdates()
        let deltaCalculator = BKDeltaCalculator.defaultCalculator { (post1 , post2) -> Bool in
            let p1 = post1 as! UserPost
            let p2 = post2 as! UserPost
            return (p1.post_id == p2.post_id);
        }
//        print("self.oldNewsfeedArray == \(self.getFeedArray())")
//        print("getFeedArray() == \(newData)")
        let delta = deltaCalculator.deltaFromOldArray(self.getFeedArray(), toNewArray:newData)
//        oldNewsfeedArray = newData
        delta.applyUpdatesToTableView(self.tableView,inSection:0,withRowAnimation:UITableViewRowAnimation.Fade)
        if(tabType == NewsfeedTabType.Following){
            XAppDelegate.dataStore.newsfeedFollowing = newData
        } else {
            XAppDelegate.dataStore.newsfeedGlobal = newData
        }
        self.tableView.endUpdates()
        
        tableView.finishInfiniteScroll()
        
    }
    
    func tableReloadWithAnimation(){
        self.tableView.dataSource?.numberOfSectionsInTableView!(self.tableView)
        tableView.reloadSections(NSIndexSet(index: 0),withRowAnimation:UITableViewRowAnimation.Fade)
    }
}
