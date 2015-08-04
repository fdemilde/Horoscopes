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
//    var userProfileArray = [UserProfile]()
    var userPostArray = [UserPost]()
    
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
        if(XAppDelegate.socialManager.isLoggedInFacebook()){ // user already loggin facebook
            dispatch_async(dispatch_get_main_queue(),{
                self.checkAndLoginZwigglers()
            })
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        currentPage = 0
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "globalFeedsFinishedLoading:", name: NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "followingFeedsFinishedLoading:", name: NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED, object: nil)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        super.viewWillDisappear(animated)
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
    
    func globalFeedsFinishedLoading(notif : NSNotification){
        if(notif.object == nil){
            Utilities.showAlertView(self,title: "",message: "No feeds available")
        } else {
            self.resetTapButtonColor()
            var newDataArray = notif.object as! [UserPost]
            userPostArray = newDataArray
            dispatch_async(dispatch_get_main_queue(),{
                self.tableReloadDataWithAnimation()
            })
        }
        Utilities.hideHUD()
    }
    
    func followingFeedsFinishedLoading(notif : NSNotification){
        Utilities.hideHUD()
        if(notif.object == nil){
            Utilities.showAlertView(self,title:"",message:"No feeds available")
            self.tabType = NewsfeedTabType.Global
            self.resetTapButtonColor()
        } else {
            self.resetTapButtonColor()
            var followingPostArray = notif.object as! [UserPost]
            self.userPostArray = followingPostArray
            self.tableReloadDataWithAnimation()
        }
        
    }
    
    // MARK: Button Actions
    
    @IBAction func selectSignBtnTapped(sender: AnyObject) {
        if(self.tabType != NewsfeedTabType.Global){
            currentPage = 0
            self.tabType = NewsfeedTabType.Global
            self.resetTapButtonColor()
            userPostArray = XAppDelegate.dataStore.newsfeedGlobal
            tableView.reloadData()
        }
        XAppDelegate.socialManager.getGlobalNewsfeed(0, isAddingData: false)
        
    }
    
    @IBAction func followingButtonTapped(sender: AnyObject) {
        if(self.tabType != NewsfeedTabType.Following){
            currentPage = 0
            self.tabType = NewsfeedTabType.Following
            self.resetTapButtonColor()
            if(XAppDelegate.socialManager.isLoggedInFacebook()){
                userPostArray = XAppDelegate.dataStore.newsfeedFollowing
                tableView.reloadData()
            } else {
                tableView.reloadData()
            }
        } else {
            if(XAppDelegate.socialManager.isLoggedInFacebook()){
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
//        println("tableView tableView nodeForRowAtIndexPath \([indexPath.row])")
        var post = userPostArray[indexPath.row] as UserPost
        var cell = PostCellNode(post: post, type: PostCellType.Newsfeed)
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        if(self.tabType == NewsfeedTabType.Global){
            self.tableView.tableHeaderView = nil
            self.tableView.backgroundColor = UIColor.clearColor()
            return 1
        }
        
        if(XAppDelegate.socialManager.isLoggedInFacebook()){ // user already loggin facebook
            self.tableView.tableHeaderView = nil
            return 1
        } else {
            var facebookBtnContainer = UIView(frame: self.tableView.bounds)
            facebookBtnContainer.layer.cornerRadius = 5
            facebookBtnContainer.backgroundColor = UIColor.whiteColor()
            facebookBtnContainer.userInteractionEnabled = true
            var facebookButton = UIButton()
            facebookButton.frame = CGRectMake((tableView.bounds.width - FB_BUTTON_SIZE)/2, (tableView.bounds.height - FB_BUTTON_SIZE)/2 - 40, FB_BUTTON_SIZE, FB_BUTTON_SIZE)
            facebookButton.addTarget(self, action: "facebookLogin:", forControlEvents: UIControlEvents.TouchUpInside)
            facebookButton.setImage(UIImage(named: "fb_login_icon"), forState: UIControlState.Normal)
            facebookBtnContainer.addSubview(facebookButton)
            var label = UILabel()
            label.text = "Login Facebook to follow your friends"
            label.sizeToFit()
            label.frame = CGRectMake((tableView.bounds.width - label.frame.size.width)/2, facebookButton.frame.origin.y + facebookButton.frame.height + 25, label.frame.size.width, label.frame.size.height) // 15 is padding b/w button and label
            facebookBtnContainer.addSubview(label)
            self.tableView.tableHeaderView = facebookBtnContainer
            return 0
        }
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
//        println("numberOfRowsInSection numberOfRowsInSection \(userPostArray.count) ")
        return userPostArray.count
    }
    
    func tableReloadDataWithAnimation(){
        self.tableView.beginUpdates()
        var range = NSMakeRange(0, self.tableView.numberOfSections());
        var sections = NSIndexSet(indexesInRange: range);
        self.tableView.reloadSections(sections, withRowAnimation: UITableViewRowAnimation.Fade)
//        self.tableView.reloadRowsAtIndexPaths(tableView.indexPathsForVisibleRows(), withRowAnimation: UITableViewRowAnimation.Fade)
        self.tableView.endUpdates()
//        self.tableView.reloadData()
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
                println("Newsfeed setupLocationService ")
//                XAppDelegate.socialManager.unfollow(11, completionHandler: { (error) -> Void in
//                    println("Did unfollow")
//                })
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
                            println("Newsfeed Following setupLocationService ")
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
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        var currentOffset = scrollView.contentOffset.y;
        var maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
        
        if (maximumOffset - currentOffset <= -40) {
            self.currentPage++
            
            if(self.tabType == NewsfeedTabType.Following){
                XAppDelegate.socialManager.getFollowingNewsfeed(self.currentPage, isAddingData: true)
            } else {
                XAppDelegate.socialManager.getGlobalNewsfeed(self.currentPage, isAddingData: true)
            }
            
        }
    }
}