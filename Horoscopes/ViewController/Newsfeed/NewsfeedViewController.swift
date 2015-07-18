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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshViewWithNewData:", name: NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED, object: nil)
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
    
    func refreshViewWithNewData(notif : NSNotification){
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
        if(self.tabType != NewsfeedTabType.SignTag){
            self.tabType = NewsfeedTabType.SignTag
            XAppDelegate.socialManager.getGlobalNewsfeed(0)
        }
        
    }
    
    @IBAction func followingButtonTapped(sender: AnyObject) {
        if(self.tabType != NewsfeedTabType.Following){
            self.tabType = NewsfeedTabType.Following
            self.resetTapButtonColor()
            if(XAppDelegate.socialManager.isLoggedInFacebook()){
                XAppDelegate.socialManager.getFollowingNewsfeed(0)
            } else {
                tableView.reloadData()
            }
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
        if(self.tabType == NewsfeedTabType.SignTag){
            self.tableView.backgroundView = nil
            self.tableView.backgroundColor = UIColor.clearColor()
            return 1
        }
        
        if(XAppDelegate.socialManager.isLoggedInFacebook()){ // user already loggin facebook
            self.tableView.backgroundColor = UIColor.clearColor()
            self.tableView.layer.cornerRadius = 0
            return 1
        } else {
            self.tableView.backgroundColor = UIColor.whiteColor()
            self.tableView.layer.cornerRadius = 5
            var facebookBtnContainer = UIView(frame: self.tableView.bounds)
            facebookBtnContainer.backgroundColor = UIColor.clearColor()
            var facebookButton = UIButton()
            facebookButton.frame = CGRectMake((tableView.bounds.width - FB_BUTTON_SIZE)/2, (tableView.bounds.height - FB_BUTTON_SIZE)/2 - 40, FB_BUTTON_SIZE, FB_BUTTON_SIZE)
            println("facebookButton.addTarget facebookButton.addTarget")
            facebookButton.addTarget(self, action: "facebookLogin:", forControlEvents: UIControlEvents.TouchUpInside)
            facebookButton.setImage(UIImage(named: "fb_login_icon"), forState: UIControlState.Normal)
            facebookBtnContainer.addSubview(facebookButton)
            var label = UILabel()
            label.text = "Login Facebook to follow your friends"
            label.sizeToFit()
            label.frame = CGRectMake((tableView.bounds.width - label.frame.size.width)/2, facebookButton.frame.origin.y + facebookButton.frame.height + 25, label.frame.size.width, label.frame.size.height) // 15 is padding b/w button and label
            facebookBtnContainer.addSubview(label)
            self.tableView.backgroundView = facebookBtnContainer
            return 0
        }
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
//        println("numberOfRowsInSection numberOfRowsInSection \(userPostArray.count) ")
        return userPostArray.count
    }
    
    func tableReloadDataWithAnimation(){
//        self.tableView.beginUpdates()
//        var range = NSMakeRange(0, self.tableView.numberOfSections());
//        var sections = NSIndexSet(indexesInRange: range);
//        self.tableView.reloadSections(sections, withRowAnimation: UITableViewRowAnimation.None)
//        self.tableView.endUpdates()
        self.tableView.reloadData()
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
                    XAppDelegate.socialManager.getFollowingNewsfeed(0)
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
                            XAppDelegate.socialManager.getFollowingNewsfeed(0)
                        })
                    }
                })
            } else {
                Utilities.hideHUD()
            }
        }
    }
    
    // MARK: Button Hide/show
    
//    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
//        startPositionY = scrollView.contentOffset.y
//    }
//    
//    func scrollViewDidScroll(scrollView: UIScrollView) {
//        var moveDistance = 0 as CGFloat
//        var currentYPosition = scrollView.contentOffset.y
//        if currentYPosition < (startPositionY - 20) {
//            setButtonsVisible(true, animated : true)
//        } else if currentYPosition > (startPositionY + 20){
//            setButtonsVisible(false, animated : true)
//        }
//        
//    }
//    
//    func setButtonsVisible(visible : Bool, animated : Bool){
//        if(self.buttonIsVisible() == visible){
//            return
//        }
//        
//        var followingFrame = self.followingButton.frame
//        var globalFrame = self.globalButton.frame
//        var height = followingFrame.size.height
//        var offsetY = 0 as CGFloat
//        var tableFrame = self.tableView.frame
//        if(visible){
//            offsetY = height
//        } else {
//            offsetY = -height
////            tableFrame = 
//        }
//        
//        var duration = 0.0 as NSTimeInterval
//        if(animated){
//            duration = 0.3
//        } else { duration = 0.0 }
//        
//        UIView.animateWithDuration(duration, animations: { () -> Void in
//            self.followingButton.frame = CGRectOffset(followingFrame, 0, offsetY)
//            self.globalButton.frame = CGRectOffset(globalFrame, 0, offsetY)
//        })
//    }
//    
//    func buttonIsVisible() -> Bool{
//        return self.followingButton.frame.origin.y >= 50
//    }
//    
//    func moveButtonsDown(moveDistance : CGFloat){
//        var MAX_POS_Y_CONSTRAINT = 18 as CGFloat
//        var MIN_POS_Y_CONSTRAINT = -self.followingButton.frame.height-10
//        var maxDistance = MAX_POS_Y_CONSTRAINT - MIN_POS_Y_CONSTRAINT
//        
//        if(self.followingPosYConstraint.constant +  moveDistance > MAX_POS_Y_CONSTRAINT){
//            followingPosYConstraint.constant = MAX_POS_Y_CONSTRAINT
//            globalButtonPosYConstraint.constant = MAX_POS_Y_CONSTRAINT
//            self.followingButton.alpha = 1
//            self.globalButton.alpha = 1
//        } else {
//            self.followingPosYConstraint.constant += moveDistance
//            self.globalButtonPosYConstraint.constant += moveDistance
//            var alphaChange = moveDistance / maxDistance * 1
//            self.followingButton.alpha = self.followingButton.alpha + alphaChange
//            self.globalButton.alpha = self.followingButton.alpha + alphaChange
//        }
//    }
//    
//    func moveButtonsUp(moveDistance : CGFloat) {
//        var MAX_POS_Y_CONSTRAINT = 18 as CGFloat
//        var MIN_POS_Y_CONSTRAINT = -self.followingButton.frame.height-10 // padding
//        var maxDistance = MAX_POS_Y_CONSTRAINT - MIN_POS_Y_CONSTRAINT
//        if(self.followingPosYConstraint.constant -  moveDistance < MIN_POS_Y_CONSTRAINT){
//            followingPosYConstraint.constant = MIN_POS_Y_CONSTRAINT
//            globalButtonPosYConstraint.constant = MIN_POS_Y_CONSTRAINT
//            self.followingButton.alpha = 0.01
//            self.globalButton.alpha = 0.01
//        } else {
//            var alphaChange = moveDistance / maxDistance * 1.5
//            self.followingPosYConstraint.constant -= moveDistance
//            self.globalButtonPosYConstraint.constant -= moveDistance
//            self.followingButton.alpha = max(self.followingButton.alpha - alphaChange, 0.01)
//            self.globalButton.alpha = max(self.followingButton.alpha - alphaChange, 0.01)
//        }
//    }
}