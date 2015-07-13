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
    
    @IBOutlet weak var globalButton: UIButton!
    @IBOutlet weak var followingButton: UIButton!
//    var userProfileArray = [UserProfile]()
    var userPostArray = [UserPost]()
    
    var feedsDisplayNode = ASDisplayNode()
    @IBOutlet weak var tableView : ASTableView!
    var tabType = NewsfeedTabType.SignTag
    var currentSelectedSign = 0 // 0 is all
    
    let MIN_SCROLL_DISTANCE_TO_HIDE_TABBAR = 30 as CGFloat
    var startPositionY = 0 as CGFloat
    
    @IBOutlet weak var globalButtonPosYConstraint : NSLayoutConstraint!
    
    @IBOutlet weak var followingPosYConstraint : NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        self.setupTableView()
        self.resetTapButtonColor()
        XAppDelegate.socialManager.getGlobalNewsfeed(0)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshViewWithNewData:", name: NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "followingFeedsFinishedLoading:", name: NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED, object: nil)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        super.viewWillDisappear(animated)
    }
    
    func setupTableView(){
//        tableView = ASTableView(frame: CGRectMake(0, ADMOD_HEIGHT + globalButton.frame.height + TABLE_PADDING_TOP, Utilities.getScreenSize().width, Utilities.getScreenSize().height - (globalButton.frame.height + TABLE_PADDING_TOP + TABLE_PADDING_BOTTOM)), style: UITableViewStyle.Plain)
        self.tableView.bounces = false
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.backgroundColor = UIColor.clearColor()
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.asyncDataSource = self
        self.tableView.asyncDelegate = self
        self.view.addSubview(tableView)
    }

    
    // MARK: Notification Handlers
    
    func refreshViewWithNewData(notif : NSNotification){
        if(notif.object == nil){
            Utilities.showAlertView(self,title: "",message: "No feeds available")
        } else {
            self.resetTapButtonColor()
            var newDataArray = notif.object as! [UserPost]
            userPostArray = newDataArray
            dispatch_async(dispatch_get_main_queue(),{
                self.tableReloadDataWithAnimation()
                self.tableView.hidden = false
                
            })
            
        }
        Utilities.hideHUD()
    }
    
    func followingFeedsFinishedLoading(notif : NSNotification){
        
        
        if(notif.object == nil){
            Utilities.hideHUD()
            Utilities.showAlertView(self,title:"",message:"No feeds available")
            self.tabType = NewsfeedTabType.SignTag
            self.resetTapButtonColor()
        } else {
            self.resetTapButtonColor()
            var followingPostArray = notif.object as! [UserPost]
            self.userPostArray = followingPostArray
            self.tableReloadDataWithAnimation()
            Utilities.hideHUD()
        }
        
    }
    
    // MARK: Button Actions
    
    @IBAction func selectSignBtnTapped(sender: AnyObject) {
//        self.printCurrentTabType()
        if(self.tabType != NewsfeedTabType.SignTag){
            self.tabType = NewsfeedTabType.SignTag
            
            XAppDelegate.socialManager.getGlobalNewsfeed(0)
            
        }
        
    }
    
    @IBAction func followingButtonTapped(sender: AnyObject) {
//        self.printCurrentTabType()
        if(self.tabType != NewsfeedTabType.Following){
            self.tabType = NewsfeedTabType.Following
            self.resetTapButtonColor()
            XAppDelegate.socialManager.getFollowingNewsfeed(0)
        }
    }
    
    func printCurrentTabType(){
        switch self.tabType {
            // Use Internationalization, as appropriate.
            case NewsfeedTabType.SignTag: println("SignTag")
            case NewsfeedTabType.Following: println("Following")
        }
    }
    
    
    
    func resetTapButtonColor(){ // change button color based on state
        switch self.tabType {
            // Use Internationalization, as appropriate.
            case NewsfeedTabType.SignTag:
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
        var cell = NewsfeedCellNode(post: post)
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
//        println("numberOfSectionsInTableView numberOfSectionsInTableView")
        return 1
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
//        println("numberOfRowsInSection numberOfRowsInSection \(userPostArray.count) ")
        return userPostArray.count
    }
    
    func tableReloadDataWithAnimation(){
        self.tableView.beginUpdates()
        var range = NSMakeRange(0, self.tableView.numberOfSections());
        var sections = NSIndexSet(indexesInRange: range);
        self.tableView.reloadSections(sections, withRowAnimation: UITableViewRowAnimation.None)
        self.tableView.endUpdates()
    }
    
    // MARK: Button Hide/show
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        startPositionY = scrollView.contentOffset.y
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var moveDistance = 0 as CGFloat
        var currentYPosition = scrollView.contentOffset.y
        if currentYPosition < startPositionY {
            moveButtonsDown(startPositionY - currentYPosition)
            startPositionY = scrollView.contentOffset.y
        } else {
            moveButtonsUp(currentYPosition - startPositionY)
            startPositionY = scrollView.contentOffset.y
        }
        
    }
    
    func moveButtonsDown(moveDistance : CGFloat){
        var MAX_POS_Y_CONSTRAINT = 18 as CGFloat
        
        if(self.followingPosYConstraint.constant +  moveDistance > MAX_POS_Y_CONSTRAINT){
            followingPosYConstraint.constant = MAX_POS_Y_CONSTRAINT
            globalButtonPosYConstraint.constant = MAX_POS_Y_CONSTRAINT
        } else {
            self.followingPosYConstraint.constant += moveDistance
            self.globalButtonPosYConstraint.constant += moveDistance
        }
    }
    
    func moveButtonsUp(moveDistance : CGFloat) {
        var MIN_POS_Y_CONSTRAINT = -self.followingButton.frame.height-10 // padding
        if(self.followingPosYConstraint.constant -  moveDistance < MIN_POS_Y_CONSTRAINT){
            followingPosYConstraint.constant = MIN_POS_Y_CONSTRAINT
            globalButtonPosYConstraint.constant = MIN_POS_Y_CONSTRAINT
        } else {
            self.followingPosYConstraint.constant -= moveDistance
            self.globalButtonPosYConstraint.constant -= moveDistance
        }
    }
}