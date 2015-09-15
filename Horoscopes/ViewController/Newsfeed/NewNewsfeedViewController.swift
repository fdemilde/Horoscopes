//
//  NewNewsfeedViewController.swift
//  Horoscopes
//
//  Created by Dang Doan on 8/21/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

class NewNewsfeedViewController: ViewControllerWithAds, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, DCPathButtonDelegate, PostTableViewCellDelegate {

    @IBOutlet weak var tableView: UITableView!
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
    let addButtonSize: CGFloat = 40
    var addButton: DCPathButton!
    
    let FB_BUTTON_SIZE = 80 as CGFloat
    let upperButtonHeight: CGFloat = 50
    lazy var screenHeight: CGFloat = UIScreen.mainScreen().bounds.height - TABBAR_HEIGHT - ADMOD_HEIGHT - self.upperButtonHeight
    lazy var minimumTextViewHeight: CGFloat = self.screenHeight - 350
    
    @IBOutlet weak var globalButton: UIButton!
    @IBOutlet weak var followingButton: UIButton!
    var userPostArray = [UserPost]()
    var feedsDisplayNode = ASDisplayNode()
    var tabType = NewsfeedTabType.Following
    var currentSelectedSign = 0 // 0 is all
    var currentPage = 0
    var overlay : UIView!
    
    @IBOutlet weak var tabView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        self.resetTapButtonColor()
        self.setupInfiniteScroll()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if(tabType == NewsfeedTabType.Following && XAppDelegate.dataStore.newsfeedFollowing.count == 0){ // only check if no data for following yet
            userPostArray = XAppDelegate.dataStore.newsfeedFollowing
            tableView.reloadData()
            if(XAppDelegate.socialManager.isLoggedInFacebook()){ // user already logged in facebook
                dispatch_async(dispatch_get_main_queue(),{
                    self.checkAndLoginZwigglers()
                })
            }
        }
        
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
        self.setupAddPostButton()
        // create tabView shadow
        tabView.layer.shadowOffset = CGSize(width: 0, height: 1)
        tabView.layer.shadowOpacity = 0.2
        tabView.layer.shadowRadius = 1
    }
    
    func setupAddPostButton() {
        addButton = DCPathButton(centerImage: UIImage(named: "newsfeed_add_btn"), highlightedImage: UIImage(named: "newsfeed_add_btn"))
        addButton.delegate = self
        addButton.dcButtonCenter = CGPointMake(view.frame.width - addButtonSize, view.frame.height - addButtonSize - TABBAR_HEIGHT)
        addButton.allowCenterButtonRotation = true
        addButton.bloomRadius = 145
        addButton.bloomDirection = kDCPathButtonBloomDirection.DCPathButtonBloomDirectionTop
        addButton.bloomAngel = 0
        
        var itemButton_1 = DCPathItemButton(image: UIImage(named: NEWFEEDS_POST_FEEL_IMG_NAME), highlightedImage: UIImage(named: NEWFEEDS_POST_FEEL_IMG_NAME), backgroundImage: UIImage(named: NEWFEEDS_POST_FEEL_IMG_NAME), backgroundHighlightedImage: UIImage(named: NEWFEEDS_POST_FEEL_IMG_NAME))
        var itemButton_2 = DCPathItemButton(image: UIImage(named: NEWFEEDS_POST_STORY_IMG_NAME), highlightedImage: UIImage(named: NEWFEEDS_POST_STORY_IMG_NAME), backgroundImage: UIImage(named: NEWFEEDS_POST_STORY_IMG_NAME), backgroundHighlightedImage: UIImage(named: NEWFEEDS_POST_STORY_IMG_NAME))
        var itemButton_3 = DCPathItemButton(image: UIImage(named: NEWFEEDS_POST_MIND_IMG_NAME), highlightedImage: UIImage(named: NEWFEEDS_POST_MIND_IMG_NAME), backgroundImage: UIImage(named: NEWFEEDS_POST_MIND_IMG_NAME), backgroundHighlightedImage: UIImage(named: NEWFEEDS_POST_MIND_IMG_NAME))
        addButton.addPathItems([itemButton_1, itemButton_2, itemButton_3])
        
        addButton.addButtonText([NEWFEEDS_POST_FEEL_TEXT, NEWFEEDS_POST_STORY_TEXT, NEWFEEDS_POST_MIND_TEXT])
        
        
        // setup overlay
        overlay = UIView(frame: CGRectMake(0, 0, Utilities.getScreenSize().width, Utilities.getScreenSize().height))
        overlay.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        overlay.hidden = true
        view.addSubview(overlay)
        view.bringSubviewToFront(overlay)
        view.addSubview(addButton)
        view.bringSubviewToFront(addButton)
    }
    
    func configureCell(cell: PostTableViewCell, post: UserPost) {
        cell.configureNewsfeedUi(minimumTextViewHeight)
        switch post.type {
        case .OnYourMind:
            cell.profileView.backgroundColor = UIColor.newsfeedMindColor()
            cell.postTypeImageView.image = UIImage(named: "post_type_mind")
        case .Feeling:
            cell.profileView.backgroundColor = UIColor.newsfeedFeelColor()
            cell.postTypeImageView.image = UIImage(named: "post_type_feel")
        case .Story:
            cell.profileView.backgroundColor = UIColor.newsfeedStoryColor()
            cell.postTypeImageView.image = UIImage(named: "post_type_story")
        }
        cell.postDateLabel.text = Utilities.getDateStringFromTimestamp(NSTimeInterval(post.ts), dateFormat: NewProfileViewController.postDateFormat)
        cell.textView.text = post.message
        cell.likeNumberLabel.text = "\(post.hearts) Likes"
        Utilities.getImageFromUrlString(post.user!.imgURL, completionHandler: { (image) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                cell.profileImageView.image = image
            })
        })
        cell.profileNameLabel.text = post.user?.name
        if NSUserDefaults.standardUserDefaults().boolForKey(String(post.post_id)) {
            cell.likeButton.setImage(UIImage(named: "newsfeed_red_heart_icon"), forState: .Normal)
            cell.likeButton.userInteractionEnabled = false
            
        } else {
            cell.likeButton.setImage(UIImage(named: "newsfeed_heart_icon"), forState: .Normal)
            cell.likeButton.userInteractionEnabled = true
        }
        
        if XAppDelegate.currentUser.uid != -1 {
            if post.uid != XAppDelegate.currentUser.uid {
                SocialManager.sharedInstance.isFollowing(post.uid, followerId: XAppDelegate.currentUser.uid, completionHandler: { (result, error) -> Void in
                    if let error = error {
                        
                    } else {
                        let isFollowing = result!["isfollowing"] as! Int == 1
                        if isFollowing {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                cell.newsfeedFollowButton.setImage(UIImage(named: "newsfeed_followed_btn"), forState: .Normal)
                                cell.newsfeedFollowButton.userInteractionEnabled = false
                            })
                        } else {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                cell.newsfeedFollowButton.setImage(UIImage(named: "newsfeed_follow_btn"), forState: .Normal)
                                cell.newsfeedFollowButton.userInteractionEnabled = true
                            })
                        }
                    }
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    cell.newsfeedFollowButton.setImage(nil, forState: .Normal)
                    cell.newsfeedFollowButton.userInteractionEnabled = false
                })
            }
        }
    }
    
    // MARK: Post buttons clicked
    // DCPathButton Delegate
    //
    func pathButton(dcPathButton: DCPathButton!, clickItemButtonAtIndex itemButtonIndex: UInt) {
        overlay.hidden = true
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("DetailPostViewController") as! DetailPostViewController
        controller.type = postTypes[Int(itemButtonIndex)][2]
        controller.placeholder = postTypes[Int(itemButtonIndex)][0]
        controller.parentVC = self
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func centerButtonTapped(){
        if(addButton.isBloom()){
            overlay.hidden = true
        } else {
            overlay.hidden = false
        }
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
        var cell = tableView.dequeueReusableCellWithIdentifier("PostTableViewCell", forIndexPath: indexPath) as! PostTableViewCell
        var post = userPostArray[indexPath.row] as UserPost
        cell.delegate = self
        cell.resetUI()
        configureCell(cell, post: post)
        return cell
    }
    
    // MARK: - Delegate
    
    func didTapNewsfeedFollowButton(cell: PostTableViewCell) {
        let index = tableView.indexPathForCell(cell)?.row
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        SocialManager.sharedInstance.follow(userPostArray[index!].uid, completionHandler: { (error) -> Void in
            hud.mode = MBProgressHUDMode.Text
            hud.detailsLabelFont = UIFont.systemFontOfSize(11)
            if let error = error {
                hud.detailsLabelText = "Follow unsuccessully due to network error!"
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    hud.hide(true, afterDelay: 2)
                })
            } else {
                let name = self.userPostArray[index!].user!.name
                hud.detailsLabelText = "\(name) has been added to your Following list."
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    cell.newsfeedFollowButton.setImage(UIImage(named: "newsfeed_followed_btn"), forState: .Normal)
                    hud.hide(true, afterDelay: 2)
                })
            }
        })
    }
    
    func didTapPostProfile(cell: PostTableViewCell) {
        if SocialManager.sharedInstance.isLoggedInFacebook() {
            let index = tableView.indexPathForCell(cell)?.row
            let profile = userPostArray[index!].user
            let controller = storyboard?.instantiateViewControllerWithIdentifier("NewProfileViewController") as! NewProfileViewController
            controller.profileType = ProfileType.OtherUser
            controller.userProfile = profile!
            navigationController?.pushViewController(controller, animated: true)
        } else {
            Utilities.showAlert(self, title: "Action Denied", message: "You have to login to Facebook to view profile!", error: nil)
        }
    }
    
    func didTapShareButton(cell: PostTableViewCell) {
        let index = tableView.indexPathForCell(cell)?.row
        let name = userPostArray[index!].user!.name
        let postContent = userPostArray[index!].message
        let sharingText = String(format: "%@ \n %@", name, postContent)
        let controller = Utilities.shareViewControllerForType(ShareViewType.ShareViewTypeHybrid, shareType: ShareType.ShareTypeNewsfeed, sharingText: sharingText)
        Utilities.presentShareFormSheetController(self, shareViewController: controller)
    }
    
    func didTapLikeButton(cell: PostTableViewCell) {
        let index = tableView.indexPathForCell(cell)?.row
        let profileId = userPostArray[index!].uid
        let postId = userPostArray[index!].post_id
        if(!XAppDelegate.socialManager.isLoggedInFacebook()){
            Utilities.showAlertView(self, title: "", message: "Must Login facebook to send heart", tag: 1)
            return
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sendHeartSuccessful:", name: NOTIFICATION_SEND_HEART_FINISHED, object: nil)
        XAppDelegate.socialManager.sendHeart(profileId, postId: postId, type: SEND_HEART_USER_POST_TYPE)
    }
    
    // Notification handler
    func sendHeartSuccessful(notif: NSNotification){
        let postId = notif.object as! String
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_SEND_HEART_FINISHED, object: nil)
        var index = -1
        for (i, post) in enumerate(userPostArray) {
            if post.post_id == postId {
                index = i
            }
        }
        if index != -1 {
            userPostArray[index].hearts += 1
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            let indexPaths = [
                indexPath
            ]
            tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
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
                    
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: "feedsFinishedLoading:", name: NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED, object: nil)
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
