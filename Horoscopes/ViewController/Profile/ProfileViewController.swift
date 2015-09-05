//
//  ProfileViewController.swift
//  Horoscopes
//
//  Created by Dang Doan on 7/30/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

//enum ProfileType {
//    case CurrentUser
//    case OtherUser
//}

class ProfileViewController: ViewControllerWithAds, ASTableViewDataSource, ASTableViewDelegate, ProfileSecondSectionHeaderViewDelegate, ProfileFollowCellNodeDelegate {
    
    var profileType: ProfileType = .CurrentUser
    enum Tab {
        case Post
        case Followers
        case Following
    }
    var currentTab = Tab.Post
    var backgroundImage: UIImage!
    var tableView: ASTableView!
    var isFirstDataLoad = true
    var isFinishedGettingUserPosts = false
    var isFinishedGettingFollowers = false
    var isFinishedGettingFollowingUsers = false
    var isDataChanged = false
    var successfulFollowed = false
    let firstSectionHeaderHeight: CGFloat = 54
    let firstSectionCellHeight: CGFloat = 233
    let secondSectionHeaderHeight: CGFloat = 80
    let secondSectionHeaderTag = 1
    var userProfile = UserProfile()
    var userPosts = [UserPost]()
    var followers = [UserProfile]()
    var followingUsers = [UserProfile]()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updatePost:", name: NOTIFICATION_UPDATE_POST, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateFollower:", name: NOTIFICATION_UPDATE_FOLLOWERS, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateFollowing:", name: NOTIFICATION_UPDATE_FOLLOWING, object: nil)
        configureUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        tableView.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y + ADMOD_HEIGHT, view.frame.width, view.frame.height - ADMOD_HEIGHT - TABBAR_HEIGHT)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if !isFirstDataLoad {
            switch currentTab {
            case .Post:
                getUserPosts()
            case .Followers:
                getFollowers()
            case .Following:
                getFollowingUsers()
            }
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - UI Configuration
    func configureUI() {
        backgroundImage = Utilities.getImageToSupportSize("background", size: view.frame.size, frame: view.bounds)
        view.backgroundColor = UIColor(patternImage: backgroundImage)
        configureTableView()
        if profileType == .CurrentUser {
            if SocialManager.sharedInstance.isLoggedInFacebook() {
                if SocialManager.sharedInstance.isLoggedInZwigglers() {
                    if XAppDelegate.currentUser.uid == -1 {
                        SocialManager.sharedInstance.persistUserProfile({ (error) -> Void in
                            if let error = error {
                                Utilities.showAlert(self, title: "Server Error", message: "There is an error on server. Please try again later.", error: error)
                            } else {
                                self.userProfile = XAppDelegate.currentUser
                                self.getDataInitially()
                            }
                        })
                    } else {
                        self.userProfile = XAppDelegate.currentUser
                        self.getDataInitially()
                    }
                } else {
                    SocialManager.sharedInstance.loginZwigglers(FBSDKAccessToken.currentAccessToken().tokenString, completionHandler: { (responseDict, error) -> Void in
                        if let error = error {
                            Utilities.showAlert(self, title: "Server Error", message: "There is an error on server. Please try again later.", error: error)
                        } else {
                            self.userProfile = XAppDelegate.currentUser
                            self.getDataInitially()
                        }
                    })
                }
            } else {
                configureLoginView()
            }
        } else {
            getDataInitially()
        }
    }
    
    func configureTableView() {
        tableView = ASTableView(frame: CGRectZero, style: UITableViewStyle.Plain, asyncDataFetching: false)
        tableView.asyncDataSource = self
        tableView.asyncDelegate = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.backgroundColor = UIColor.clearColor()
        view.addSubview(tableView)
    }
    
    func configureLoginView() {
        let headerFrame = CGRectMake(view.frame.origin.x, view.frame.origin.y + ADMOD_HEIGHT, view.frame.width, view.frame.height - ADMOD_HEIGHT - TABBAR_HEIGHT)
        let headerView = UIView(frame: headerFrame)
        let padding: CGFloat = 8
        tableView.tableHeaderView = headerView
        
        let facebookLoginButton = UIButton()
        let facebookLoginImage = UIImage(named: "fb_login_icon")
        facebookLoginButton.setImage(facebookLoginImage, forState: UIControlState.Normal)
        facebookLoginButton.sizeToFit()
        facebookLoginButton.frame = CGRectMake(headerFrame.width/2 - facebookLoginButton.frame.width/2, headerFrame.height/2 - facebookLoginButton.frame.height/2, facebookLoginButton.frame.width, facebookLoginButton.frame.height)
        facebookLoginButton.addTarget(self, action: "login:", forControlEvents: UIControlEvents.TouchUpInside)
        headerView.addSubview(facebookLoginButton)
        
        let facebookLoginLabel = UILabel()
        facebookLoginLabel.text = "You need to login to Facebook\nto enjoy this feature"
        facebookLoginLabel.textColor = UIColor.lightTextColor()
        facebookLoginLabel.numberOfLines = 2
        facebookLoginLabel.sizeToFit()
        facebookLoginLabel.textAlignment = NSTextAlignment.Center
        facebookLoginLabel.frame = CGRectMake(headerFrame.width/2 - facebookLoginLabel.frame.width/2, facebookLoginButton.frame.origin.y + facebookLoginButton.frame.height + padding, facebookLoginLabel.frame.width, facebookLoginLabel.frame.height)
        headerView.addSubview(facebookLoginLabel)
    }
    
    // MARK: - Action
    func login(sender: UIButton) {
        Utilities.showHUD()
        SocialManager.sharedInstance.login { (error, permissionGranted) -> Void in
            if let error = error {
                Utilities.showAlert(self, title: "Log In Error", message: "Could not log in to Facebook. Please try again later.", error: error)
            } else {
                if permissionGranted {
                    if XAppDelegate.currentUser.uid == -1 {
                        SocialManager.sharedInstance.persistUserProfile({ (error) -> Void in
                            if let error = error {
                                Utilities.showAlert(self, title: "Server Error", message: "There is an error on server. Please try again later.", error: error)
                            } else {
                                self.userProfile = XAppDelegate.currentUser
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    self.tableView.tableHeaderView = nil
                                    self.getDataInitially()
                                })
                            }
                        })
                    } else {
                        self.userProfile = XAppDelegate.currentUser
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.tableView.tableHeaderView = nil
                            self.getDataInitially()
                        })
                    }
                } else {
                    Utilities.showAlert(self, title: "Permission Denied", message: "Not enough permission is granted.", error: nil)
                }
            }
        }
    }
    
    // MARK: - Helper
    func getUserPosts() {
        SocialManager.sharedInstance.getUserFeed(userProfile.uid, completionHandler: { (result, error) -> Void in
            if let error = error {
                
            } else {
                self.isFinishedGettingUserPosts = true
                if self.profileType == .CurrentUser {
                    DataStore.sharedInstance.userPosts = result!
                } else {
                    self.updateData(&self.userPosts, newData: result!)
                }
            }
        })
    }
    
    func getFollowers() {
        if profileType == .CurrentUser {
            SocialManager.sharedInstance.getCurrentUserFollowersProfile { (result, error) -> Void in
                if let error = error {
                    
                } else {
                    self.isFinishedGettingFollowers = true
                    DataStore.sharedInstance.followers = result!
                }
            }
        } else {
            SocialManager.sharedInstance.getOtherUserFollowersProfile(userProfile.uid, completionHandler: { (result, error) -> Void in
                if let error = error {
                    
                } else {
                    self.isFinishedGettingFollowers = true
                    self.updateData(&self.followers, newData: result!)
                }
            })
        }
    }
    
    func getFollowingUsers() {
        if profileType == .CurrentUser {
            SocialManager.sharedInstance.getCurrentUserFollowingProfile { (result, error) -> Void in
                if let error = error {
                    
                } else {
                    self.isFinishedGettingFollowingUsers = true
                    DataStore.sharedInstance.followingUsers = result!
                }
            }
        } else {
            SocialManager.sharedInstance.getOtherUserFollowingProfile(userProfile.uid, completionHandler: { (result, error) -> Void in
                if let error = error {
                    
                } else {
                    self.isFinishedGettingFollowingUsers = true
                    self.updateData(&self.followingUsers, newData: result!)
                }
            })
        }
    }
    
    func reloadButton() {
        if let headerView = tableView?.viewWithTag(secondSectionHeaderTag) as? ProfileSecondSectionHeaderView {
            switch currentTab {
            case .Post:
                headerView.reloadButtonTitleLabel(headerView.postButton)
            case .Followers:
                headerView.reloadButtonTitleLabel(headerView.followersButton)
            case .Following:
                headerView.reloadButtonTitleLabel(headerView.followingButton)
            }
        }
    }
    
    func reloadTableView() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if self.isFirstDataLoad {
                if self.isFinishedGettingUserPosts && self.isFinishedGettingFollowers && self.isFinishedGettingFollowingUsers {
                    self.finishGettingDataInitially()
                }
            } else {
                self.reloadSection(1)
            }
        })
    }
    
    func checkFollowerStatus() {
        for (index, follower) in enumerate(followers) {
            for followingUser in followingUsers {
                if follower.uid == followingUser.uid {
                    if profileType == .CurrentUser {
                        DataStore.sharedInstance.followers[index].isFollowed = true
                    }
                    follower.isFollowed = true
                    break
                }
            }
        }
    }
    
    func finishGettingDataInitially() {
        checkFollowerStatus()
        reloadData()
        self.isFirstDataLoad = false
        self.isFinishedGettingUserPosts = false
        self.isFinishedGettingFollowers = false
        self.isFinishedGettingFollowingUsers = false
        tableView.hidden = false
        Utilities.hideHUD()
    }
    
    // MARK: - Convenience
    func updateData<T: SequenceType>(inout oldData: T, newData: T) {
        if isFirstDataLoad {
            oldData = newData
            reloadTableView()
        } else if DataStore.sharedInstance.isDataUpdated(oldData, newData: newData) {
            oldData = newData
            reloadTableView()
        }
    }
    
    func updatePost(notification: NSNotification) {
        userPosts = DataStore.sharedInstance.userPosts
        reloadTableView()
    }
    
    func updateFollower(notification: NSNotification) {
        followers = DataStore.sharedInstance.followers
        if !isFirstDataLoad {
            checkFollowerStatus()
        }
        reloadTableView()
    }
    
    func updateFollowing(notification: NSNotification) {
        followingUsers = DataStore.sharedInstance.followingUsers
        if successfulFollowed {
            checkFollowerStatus()
            successfulFollowed = false
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                Utilities.hideHUD()
            })
            
        }
        reloadTableView()
    }
    
    func getDataInitially() {
        Utilities.showHUD()
        tableView.hidden = true
        currentTab = .Post
        getUserPosts()
        getFollowers()
        getFollowingUsers()
    }
    
    func reloadData() {
        reloadSection(0)
        reloadSection(1)
    }
    
    func reloadSection(section: Int) {
        reloadButton()
        let range = NSMakeRange(section, 1)
        let section = NSIndexSet(indexesInRange: range)
        tableView?.reloadSections(section, withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    func tapButton() {
        reloadSection(1)
        switch currentTab {
        case .Post:
            getUserPosts()
        case .Followers:
            getFollowers()
        case .Following:
            getFollowingUsers()
        }
    }
    
    // MARK: - Data source and delegate
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        switch currentTab {
        case .Post:
            return userPosts.count
        case .Followers:
            return followers.count
        case .Following:
            return followingUsers.count
        }
    }
    
    func tableView(tableView: ASTableView!, nodeForRowAtIndexPath indexPath: NSIndexPath!) -> ASCellNode! {
        if indexPath.section == 0 {
            let cell = ProfileFirstSectionCellNode(userProfile: userProfile)
            return cell
        } else {
            switch currentTab {
            case .Post:
                let post = userPosts[indexPath.row]
                return PostCellNode(post: post, type: .Profile, parentViewController: self)
            case .Followers:
                let follower = followers[indexPath.row]
                let cell = ProfileFollowCellNode(user: follower, parentViewController: self)
                cell.delegate = self
                return cell
            case .Following:
                let followingUser = followingUsers[indexPath.row]
                return ProfileFollowCellNode(user: followingUser, parentViewController: self)
            }
        }
    }
    
    func tableView(tableView: UITableView!, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return firstSectionHeaderHeight
        }
        return secondSectionHeaderHeight
    }
    
    func tableView(tableView: UITableView!, viewForHeaderInSection section: Int) -> UIView! {
        if section == 0 {
            let view = ProfileFirstSectionHeaderView(frame: CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.width, firstSectionHeaderHeight), parentViewController: self)
            return view
        }
        let view = ProfileSecondSectionHeaderView(frame: CGRectMake(tableView.frame.origin.x, firstSectionHeaderHeight + firstSectionCellHeight, tableView.frame.width, secondSectionHeaderHeight), userProfile: userProfile, parentViewController: self)
        view.delegate = self
        view.followDelegate = self
        view.tag = secondSectionHeaderTag
        return view
    }
    
    func didTapPostButton() {
        if currentTab != .Post {
            currentTab = .Post
            tapButton()
        }
    }
    
    func didTapFollowersButton() {
        if currentTab != .Followers {
            currentTab = .Followers
            tapButton()
        }
    }
    
    func didTapFollowingButton() {
        if currentTab != .Following {
            currentTab = .Following
            tapButton()
        }
    }
    
    func didClickFollowButton(uid: Int) {
        Utilities.showHUD()
        SocialManager.sharedInstance.follow(uid, completionHandler: { (error) -> Void in
            if let error = error {
                
            } else {
                SocialManager.sharedInstance.sendFollowNotification(uid)
                if self.profileType == .CurrentUser {
                    self.successfulFollowed = true
                    self.getFollowingUsers()
                } else {
                    if let view = self.view.viewWithTag(self.secondSectionHeaderTag) as? ProfileSecondSectionHeaderView {
                        if let button = view.followButton {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                button.removeFromSuperview()
                            })
                        }
                    }
                    Utilities.hideHUD()
                }
            }
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
