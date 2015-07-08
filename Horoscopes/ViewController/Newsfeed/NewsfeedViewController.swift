//
//  NewsfeedViewController.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/30/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
import UIKit

class NewsfeedViewController : UIViewController, UIAlertViewDelegate, ASTableViewDataSource, ASTableViewDelegate {
    
    let TABLE_PADDING_TOP = 20 as CGFloat
    let TABLE_PADDING_BOTTOM = 49 as CGFloat
    
    let SCROLLVIEW_PADDING_LEFT = 7 as CGFloat
    let SCROLLVIEW_PADDING_RIGHT = 7 as CGFloat
    
    @IBOutlet weak var selectHoroscopeSignButton: UIButton!
    @IBOutlet weak var followingButton: UIButton!
//    var userProfileArray = [UserProfile]()
    var userPostArray = [UserPost]()
    
    var feedsDisplayNode = ASDisplayNode()
    var tableView : ASTableView!
    var tabType = NewsfeedTabType.SignTag
//    var followingCollectionView = UICollectionView()
    var currentSelectedSign = 0 // 0 is all
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        self.setupTableView()
//        self.setupFollowingCollectionView()
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
        tableView = ASTableView(frame: CGRectMake(0, selectHoroscopeSignButton.frame.height + TABLE_PADDING_TOP, Utilities.getScreenSize().width, Utilities.getScreenSize().height - (selectHoroscopeSignButton.frame.height + TABLE_PADDING_TOP + TABLE_PADDING_BOTTOM)), style: UITableViewStyle.Plain)
        self.tableView.bounces = true
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.backgroundColor = UIColor.clearColor()
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.asyncDataSource = self
        self.tableView.asyncDelegate = self
        self.view.addSubview(tableView)
    }
    
    func setupFollowingCollectionView(){
//        self.followingCollectionView.delegate = self
//        followingCollectionView.frame = CGRectMake(SCROLLVIEW_PADDING_LEFT, selectHoroscopeSignButton.frame.height + TABLE_PADDING_TOP, Utilities.getScreenSize().width - SCROLLVIEW_PADDING_RIGHT * 2, Utilities.getScreenSize().height - (selectHoroscopeSignButton.frame.height + TABLE_PADDING_TOP + TABLE_PADDING_BOTTOM))
//        followingCollectionView.layer.cornerRadius = 5
//        followingCollectionView.layer.masksToBounds = true
//        followingCollectionView.showsHorizontalScrollIndicator = false
//        followingCollectionView.showsVerticalScrollIndicator = false
//        followingCollectionView.backgroundColor = UIColor(red: 241.0/255.0, green: 241.0/255.0, blue: 241.0/255.0, alpha: 1)
//        followingCollectionView.hidden = true
//        self.view.addSubview(followingCollectionView)
    }

    
    // MARK: Notification Handlers
    
    func refreshViewWithNewData(notif : NSNotification){
        
        
        if(notif.object == nil){
            Utilities.showAlertView(self,title: "",message: "No feeds available")
        } else {
            println("refreshViewWithNewData refreshViewWithNewData")
            
            var newDataArray = notif.object as! [UserPost]
            userPostArray = newDataArray
            dispatch_async(dispatch_get_main_queue(),{
                self.tableReloadDataWithAnimation()
//                self.followingCollectionView.hidden = true
                self.tableView.hidden = false
                
            })
            
        }
        Utilities.hideHUD()
    }
    
    func followingFeedsFinishedLoading(notif : NSNotification){
        
//        if(notif.object == nil){
//            Utilities.showAlertView(self,title:"",message:"No feeds available")
//        } else {
//            dispatch_async(dispatch_get_main_queue(),{
//                self.tableView.hidden = true
//                self.followingCollectionView.hidden = false
//            })
//            var followingPostArray = notif.object as! [UserPost]
////            self.userPostArray = followingPostArray
//        }
//        Utilities.hideHUD()
        
    }
    
    // MARK: Button Actions
    
    @IBAction func selectSignBtnTapped(sender: AnyObject) {
        println("selectSignBtnTapped TAPPED!! ")
        self.printCurrentTabType()
        if(self.tabType != NewsfeedTabType.SignTag){
            println("selectSignBtnTapped selectSignBtnTapped")
            self.tabType = NewsfeedTabType.SignTag
            self.resetTapButtonColor()
            XAppDelegate.socialManager.getGlobalNewsfeed(0)
            
        }
        
    }
    
    @IBAction func followingButtonTapped(sender: AnyObject) {
        println("followingButtonTapped TAPPED!! ")
        self.printCurrentTabType()
        if(self.tabType != NewsfeedTabType.Following){
            
            println("followingButtonTapped followingButtonTapped")
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
                selectHoroscopeSignButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                followingButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
                break
            case NewsfeedTabType.Following:
                selectHoroscopeSignButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
                followingButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                break
        }
    }
    
    // MARK: Table datasource and delegate
    
    func tableView(tableView: ASTableView!, nodeForRowAtIndexPath indexPath: NSIndexPath!) -> ASCellNode! {
        println("tableView tableView nodeForRowAtIndexPath \([indexPath.row])")
        var post = userPostArray[indexPath.row] as UserPost
        var cell = NewsfeedCellNode(post: post)
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        println("numberOfSectionsInTableView numberOfSectionsInTableView")
        return 1
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        println("numberOfRowsInSection numberOfRowsInSection \(userPostArray.count) ")
        return userPostArray.count
    }
    
    func tableReloadDataWithAnimation(){
        self.tableView.beginUpdates()
        var range = NSMakeRange(0, self.tableView.numberOfSections());
        var sections = NSIndexSet(indexesInRange: range);
        self.tableView.reloadSections(sections, withRowAnimation: UITableViewRowAnimation.None)
        self.tableView.endUpdates()
    }

}