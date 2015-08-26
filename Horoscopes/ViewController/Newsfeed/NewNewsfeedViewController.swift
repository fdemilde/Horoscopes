//
//  NewNewsfeedViewController.swift
//  Horoscopes
//
//  Created by Dang Doan on 8/21/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

class NewNewsfeedViewController: ViewControllerWithAds, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    let defaultEstimatedRowHeight: CGFloat = 400
    let spaceBetweenCell: CGFloat = 11
    let addButtonSize: CGFloat = 44
    var addButton: UIButton!
    
    let FB_BUTTON_SIZE = 80 as CGFloat
    
    @IBOutlet weak var globalButton: UIButton!
    @IBOutlet weak var followingButton: UIButton!
    var userPostArray = [UserPost]()
    var oldUserPostArray = [UserPost]()
    var feedsDisplayNode = ASDisplayNode()
    var tabType = NewsfeedTabType.Following
    var currentSelectedSign = 0 // 0 is all
    var currentPage = 0
    
    @IBOutlet weak var tabView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Setup View
    func setupView(){
        // Do any additional setup after loading the view.
        let backgroundImage = Utilities.getImageToSupportSize("background", size: view.frame.size, frame: view.bounds)
        view.backgroundColor = UIColor(patternImage: backgroundImage)
        tableView.estimatedRowHeight = defaultEstimatedRowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        addButton = UIButton(frame: CGRect(x: view.frame.width - addButtonSize, y: view.frame.height - addButtonSize - TABBAR_HEIGHT, width: addButtonSize, height: addButtonSize))
        addButton.setImage(UIImage(named: "newsfeed_add_btn"), forState: .Normal)
        view.addSubview(addButton)
        view.bringSubviewToFront(addButton)
        
        // create tabView shadow
        tabView.layer.shadowOffset = CGSize(width: 0, height: 1)
        tabView.layer.shadowOpacity = 0.2
        tabView.layer.shadowRadius = 1
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
    
    // MARK: - Table view data source and delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userPostArray.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NewsfeedTableViewCell", forIndexPath: indexPath) as! NewsfeedTableViewCell
        var post = userPostArray[indexPath.row] as UserPost
        cell.populateData(post, type: PostCellType.Newsfeed, parentViewController: self)
        return cell
    }
    
//    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return spaceBetweenCell
//    }
    
//    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view = UIView()
//        view.backgroundColor = UIColor.clearColor()
//        return view
//    }
    
    // Networks 
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
        XAppDelegate.socialManager.login { (error, permissionGranted) -> Void in
            Utilities.hideHUD()
            if(error != nil){
                Utilities.showAlertView(self, title: "Error occured", message: "Try again later")
                return
            } else {
                if(permissionGranted == false){
                    Utilities.showAlertView(self, title: "Permission denied", message: "Please check your permission again")
                    return
                } else {
                    dispatch_async(dispatch_get_main_queue(),{
                        XAppDelegate.socialManager.getFollowingNewsfeed(0, isAddingData: false)
                    })
                }
            }
        }
    }
    
    // MARK: Helpers
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
    
    // MARK: infinite scrolling support 
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
}
