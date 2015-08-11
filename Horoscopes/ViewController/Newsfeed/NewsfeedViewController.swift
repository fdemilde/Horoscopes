//
//  NewsfeedViewController.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/30/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
import UIKit

class NewsfeedViewController : MyViewController, UIAlertViewDelegate, ASTableViewDataSource, ASTableViewDelegate {
    
    let TABLE_PADDING_TOP = 20 as CGFloat
    let TABLE_PADDING_BOTTOM = 49 as CGFloat
    
    let SCROLLVIEW_PADDING_LEFT = 7 as CGFloat
    let SCROLLVIEW_PADDING_RIGHT = 7 as CGFloat
    
    let FB_BUTTON_SIZE = 80 as CGFloat
    
    @IBOutlet weak var globalButton: UIButton!
    @IBOutlet weak var followingButton: UIButton!
    var userPostArray = [UserPost]()
    var oldUserPostArray = [UserPost]()
    var feedsDisplayNode = ASDisplayNode()
    @IBOutlet weak var tableView : ASTableView!
    var tabType = NewsfeedTabType.Following
    var currentSelectedSign = 0 // 0 is all
    
    let MIN_SCROLL_DISTANCE_TO_HIDE_TABBAR = 30 as CGFloat
    var startPositionY = 0 as CGFloat
    var currentPage = 0
    
    @IBOutlet weak var globalButtonPosYConstraint : NSLayoutConstraint!
    
    @IBOutlet weak var followingPosYConstraint : NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var image = Utilities.getImageToSupportSize("background", size: self.view.frame.size, frame: self.view.bounds)
        self.view.backgroundColor = UIColor(patternImage: image)
        
        self.setupTableView()
        self.resetTapButtonColor()
        self.setupInfiniteScroll()
        if(XAppDelegate.socialManager.isLoggedInFacebook()){ // user already loggin facebook
            dispatch_async(dispatch_get_main_queue(),{
                self.checkAndLoginZwigglers()
            })
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "feedsFinishedLoading:", name: NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "feedsFinishedLoading:", name: NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func setupTableView(){
        self.tableView.bounces = true
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.backgroundColor = UIColor.clearColor()
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.asyncDataSource = self
        self.tableView.asyncDelegate = self
        self.view.addSubview(tableView)
    }
    
    
    // MARK: Notification Handlers
    
    func feedsFinishedLoading(notif : NSNotification){
        Utilities.hideHUD()
        if(notif.object == nil){
            tableView.finishInfiniteScroll()
        } else {
            self.resetTapButtonColor()
            var newDataArray = notif.object as! [UserPost]
            self.insertRowsAtBottom(newDataArray)
        }
    }
    
    // MARK: Button Actions
    
    @IBAction func globalBtnTapped(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED, object: nil)
        currentPage = 0
        tableView.finishInfiniteScroll()
        XAppDelegate.dataStore.resetPage()
        if(self.tabType != NewsfeedTabType.Global){
            self.tabType = NewsfeedTabType.Global
            self.resetTapButtonColor()
            userPostArray = XAppDelegate.dataStore.newsfeedGlobal
            tableView.reloadData()
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "feedsFinishedLoading:", name: NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED, object: nil)
        XAppDelegate.socialManager.getGlobalNewsfeed(0, isAddingData: false)
    }
    
    @IBAction func followingButtonTapped(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED,object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED, object: nil)
        // when button is tapped, we load data again
        currentPage = 0
        tableView.finishInfiniteScroll()
        XAppDelegate.dataStore.resetPage()
        if(self.tabType != NewsfeedTabType.Following){
            self.tabType = NewsfeedTabType.Following
            self.resetTapButtonColor()
            if(XAppDelegate.socialManager.isLoggedInFacebook()){
                userPostArray = XAppDelegate.dataStore.newsfeedFollowing
                tableView.reloadData()
                
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "feedsFinishedLoading:", name: NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED, object: nil)
                XAppDelegate.socialManager.getFollowingNewsfeed(0, isAddingData: false)
            } else {
                userPostArray.removeAll(keepCapacity: false)
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
    
    func printCurrentTabType(){
        switch self.tabType {
            // Use Internationalization, as appropriate.
        case NewsfeedTabType.Global: println("Global")
        case NewsfeedTabType.Following: println("Following")
        }
    }
    
    
    
    func resetTapButtonColor(){ // change button color based on state
        switch self.tabType {
            // Use Internationalization, as appropriate.
        case NewsfeedTabType.Global:
            globalButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            followingButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            break
        case NewsfeedTabType.Following:
            globalButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            followingButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            break
        }
    }
    
    // MARK: Table datasource and delegate
    
    func tableView(tableView: ASTableView!, nodeForRowAtIndexPath indexPath: NSIndexPath!) -> ASCellNode! {
        var post = userPostArray[indexPath.row] as UserPost
        var cell = PostCellNode(post: post, type: PostCellType.Newsfeed, parentViewController: self)
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        if(XAppDelegate.socialManager.isLoggedInFacebook() || self.tabType == NewsfeedTabType.Global){ // user already loggin facebook
            tableView.tableHeaderView = nil
        } else {
            var bg = self.createEmptyTableHeaderBackground()
            var facebookButton = UIButton()
            facebookButton.frame = CGRectMake((tableView.bounds.width - FB_BUTTON_SIZE)/2, (tableView.bounds.height - FB_BUTTON_SIZE)/2 - 40, FB_BUTTON_SIZE, FB_BUTTON_SIZE)
            facebookButton.addTarget(self, action: "facebookLogin:", forControlEvents: UIControlEvents.TouchUpInside)
            facebookButton.setImage(UIImage(named: "fb_login_icon"), forState: UIControlState.Normal)
            bg.addSubview(facebookButton)
            var label = UILabel()
            label.text = "Login Facebook to follow your friends"
            label.sizeToFit()
            label.frame = CGRectMake((tableView.bounds.width - label.frame.size.width)/2, facebookButton.frame.origin.y + facebookButton.frame.height + 25, label.frame.size.width, label.frame.size.height) // 15 is padding b/w button and label
            bg.addSubview(label)
            tableView.tableHeaderView = bg
        }
        return 1
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return userPostArray.count
    }
    
    func insertRowsAtBottom(newData : [UserPost]){
        self.tableView.beginUpdates()
        var deltaCalculator = BKDeltaCalculator.defaultCalculator { (post1 , post2) -> Bool in
            var p1 = post1 as! UserPost
            var p2 = post2 as! UserPost
            return (p1.post_id == p2.post_id);
        }
        var delta = deltaCalculator.deltaFromOldArray(self.userPostArray, toNewArray:newData)
        self.userPostArray = newData
        delta.applyUpdatesToTableView(self.tableView,inSection:0,withRowAnimation:UITableViewRowAnimation.Fade)
        
        
        if(self.userPostArray.count != 0){
            self.tableView.tableHeaderView = nil
            self.tableView.backgroundColor = UIColor.clearColor()
        } else {
            self.tableView.tableHeaderView = self.createEmptyTableHeaderBackgroundWithMessage()
        }
        self.tableView.endUpdates()
        tableView.finishInfiniteScroll()
        
    }
    
    func tableReloadWithAnimation(){
        self.tableView.dataSource?.numberOfSectionsInTableView!(self.tableView)
        tableView.reloadSections(NSIndexSet(index: 0),withRowAnimation:UITableViewRowAnimation.Fade)
    }
    
    func finishInfiniteScroll() {
        tableView.finishInfiniteScroll()
    }
    
    func clearEmptyTableBackground(){
        self.tableView.backgroundView = nil
    }
    
    func checkAndLoginZwigglers(){
        Utilities.showHUD()
        XAppDelegate.socialManager.loginZwigglers(FBSDKAccessToken .currentAccessToken().tokenString, completionHandler: { (result, error) -> Void in
            if(error != nil){
                Utilities.showAlertView(self, title: "Error occured", message: "Try again later")
                Utilities.hideHUD()
            } else {
                XAppDelegate.locationManager.setupLocationService()
                XAppDelegate.socialManager.getFollowingNewsfeed(0, isAddingData: false)
            }
        })
    }
    
    // MARK: facebook
    func facebookLogin(sender: UIButton!) {
        Utilities.showHUD()
        XAppDelegate.socialManager.loginFacebook { (result, error) -> () in
            if(error == nil && FBSDKAccessToken.currentAccessToken() != nil){ // error
                XAppDelegate.socialManager.loginZwigglers(FBSDKAccessToken.currentAccessToken().tokenString, completionHandler: { (myresult, myerror) -> Void in
                    if(myerror != nil){
                        Utilities.showAlertView(self, title: "Error occured", message: "Try again later")
                        Utilities.hideHUD()
                    } else {
                        dispatch_async(dispatch_get_main_queue(),{
                            XAppDelegate.locationManager.setupLocationService()
                            XAppDelegate.socialManager.getFollowingNewsfeed(0, isAddingData: false)
                        })
                    }
                })
            } else {
                Utilities.hideHUD()
            }
        }
    }
    
    // MARK: Button Hide/show
    
    func setupInfiniteScroll(){
        tableView.infiniteScrollIndicatorStyle = .White
        tableView.addInfiniteScrollWithHandler { (scrollView) -> Void in
            let tableView = scrollView as! UITableView
            
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
                XAppDelegate.socialManager.getFollowingNewsfeed(self.currentPage, isAddingData: true)
            } else {
                XAppDelegate.socialManager.getGlobalNewsfeed(self.currentPage, isAddingData: true)
            }
            
            
        }
    }
    
    // MARK: Helpers
    
    // if no feed to show or user doesn't log in, show white background
    func createEmptyTableHeaderBackground() -> UIView{
        var bg = UIView(frame: self.tableView.bounds)
        bg.layer.cornerRadius = 5
        bg.backgroundColor = UIColor.whiteColor()
        bg.userInteractionEnabled = true
        return bg
    }
    
    func createEmptyTableHeaderBackgroundWithMessage() -> UIView{
        var bg = self.createEmptyTableHeaderBackground()
        if(tabType == NewsfeedTabType.Following){
            if(!XAppDelegate.socialManager.isLoggedInFacebook()){
                var facebookButton = UIButton()
                facebookButton.frame = CGRectMake((tableView.bounds.width - FB_BUTTON_SIZE)/2, (tableView.bounds.height - FB_BUTTON_SIZE)/2 - 40, FB_BUTTON_SIZE, FB_BUTTON_SIZE)
                facebookButton.addTarget(self, action: "facebookLogin:", forControlEvents: UIControlEvents.TouchUpInside)
                facebookButton.setImage(UIImage(named: "fb_login_icon"), forState: UIControlState.Normal)
                bg.addSubview(facebookButton)
                var label = UILabel()
                label.text = "Login Facebook to follow your friends"
                label.sizeToFit()
                label.frame = CGRectMake((tableView.bounds.width - label.frame.size.width)/2, facebookButton.frame.origin.y + facebookButton.frame.height + 25, label.frame.size.width, label.frame.size.height) // 15 is padding b/w button and label
                bg.addSubview(label)
                return bg
            }
        }
        
        var label = UILabel()
        label.text = "No feeds available"
        label.sizeToFit()
        label.frame = CGRectMake((tableView.bounds.width - label.frame.size.width)/2, (tableView.bounds.height - label.frame.size.height)/2, label.frame.size.width, label.frame.size.height)
        bg.addSubview(label)
        return bg
    }
}