//
//  NewsfeedViewController.swift
//  Horoscopes
//
//  Created by Dang Doan on 8/21/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

class NewsfeedViewController: ViewControllerWithAds, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate {
    
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
//    var tabType = NewsfeedTabType.Following
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
        self.setupInfiniteScroll()
        tableHeaderView = NewsfeedTableHeaderView(frame: CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.frame.width, height: 40))
        tableHeaderView.setupDate(NSDate())
        tableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // remove all observer first
        NSNotificationCenter.defaultCenter().removeObserver(self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "feedsFinishedLoading:", name: NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateFollowingStatusFinished:", name: NOTIFICATION_UPDATE_FOLLOWING_STATUS_FINISHED, object: nil)
        if(XAppDelegate.dataStore.newsfeedFollowing.count == 0){ // only check if no data for following yet
            tableView.reloadData()
            if(XAppDelegate.socialManager.isLoggedInFacebook()){ // user already logged in facebook
                dispatch_async(dispatch_get_main_queue(),{
                    self.checkAndLoginZwigglers()
                })
            }
            
        }
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
                
                XAppDelegate.dataStore.newsfeedFollowing = newDataArray
//                let indexPath = NSIndexPath(forRow: XAppDelegate.dataStore.newsfeedFollowing.count - 1, inSection: 0)
//                self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
//                [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self->testArray.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
                self.tableView.reloadData()
                self.tableView.finishInfiniteScroll()
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
        XAppDelegate.socialManager.getFollowingNewsfeed(0, isAddingData: false)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "feedsFinishedLoading:", name: NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED, object: nil)
        
//        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    // MARK: - Table view data source and delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getTotalRowsInTable()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if(!XAppDelegate.socialManager.isLoggedInFacebook()){
            // if Following tab and not logged in, show log in view
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
        // Set custom indicator
        tableView.infiniteScrollIndicatorView = CustomInfiniteIndicator(frame: CGRectMake(0, 0, 24, 24))
        
        // Set custom indicator margin
        tableView.infiniteScrollIndicatorMargin = 40
        
        tableView.addInfiniteScrollWithHandler { (scrollView) -> Void in
            if(!XAppDelegate.socialManager.isLoggedInFacebook()){
                self.tableView.finishInfiniteScroll()
                return
            }
            
            if(XAppDelegate.dataStore.isLastPage){
                self.tableView.finishInfiniteScroll()
                return
            } // last page dont need to request more
            self.currentPage++
            XAppDelegate.socialManager.getFollowingNewsfeed(self.currentPage, isAddingData: true)
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
        let font = UIFont(name: "Book Antiqua", size: 14)
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
        result += XAppDelegate.dataStore.newsfeedFollowing.count
        return result
    }
    
    func getFeedDataForRow(row : Int) -> UserPost {
        return XAppDelegate.dataStore.newsfeedFollowing[row]
    }
    
    func getFeedArray() -> [UserPost]{
        return XAppDelegate.dataStore.newsfeedFollowing
    }
    
    // MARK: infinite scrolling support
    
    func tableReloadWithAnimation(){
        self.tableView.dataSource?.numberOfSectionsInTableView!(self.tableView)
        tableView.reloadSections(NSIndexSet(index: 0),withRowAnimation:UITableViewRowAnimation.Fade)
    }
}
