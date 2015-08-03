//
//  ProfileViewController.swift
//  Horoscopes
//
//  Created by Dang Doan on 7/30/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

enum ProfileType {
    case CurrentUser
    case OtherUser
}

class ProfileViewController: UIViewController, ASTableViewDataSource, ASTableViewDelegate, ProfileTabDelegate {
    
    var profileType: ProfileType!
    var currentUser: UserProfile?
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
    let secondSectionHeaderHeight: CGFloat = 80
    
    // MARK: - Initialization
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//    }
//    
//    convenience init(profileType: ProfileType) {
//        self.init(nibName: nil, bundle: nil)
//        self.profileType = profileType
//    }
//
//    required init(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureUI()
        // TODO: Comment this code when finish refactoring
        profileType = .CurrentUser
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
//        println("viewWillLayoutSubviews")
        tableView.frame = view.bounds
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        println("viewWillAppear")
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
    
    // MARK: - UI Configuration
    func configureUI() {
        backgroundImage = Utilities.getImageToSupportSize("background", size: view.frame.size, frame: view.bounds)
        view.backgroundColor = UIColor(patternImage: backgroundImage)
        configureTableView()
    }
    
    func configureTableView() {
        tableView = ASTableView(frame: CGRectZero, style: UITableViewStyle.Plain, asyncDataFetching: false)
//        tableView.frame = view.bounds
        tableView.asyncDataSource = self
        tableView.asyncDelegate = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.backgroundColor = UIColor.clearColor()
        view.addSubview(tableView)
        if SocialManager.sharedInstance.isLoggedInZwigglers() {
            getDataInitially()
        } else {
            configureLoginView()
        }
    }
    
    func configureLoginView() {
//        println("configureLoginView")
        let headerFrame = UIScreen.mainScreen().bounds
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
        SocialManager.sharedInstance.login { (error) -> Void in
            if let error = error {
                
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.tableHeaderView = nil
                    self.getDataInitially()
                })
            }
        }
    }
    
    // MARK: - Helper
    func getUserPosts() {
        let uid = XAppDelegate.mobilePlatform.userCred.getUid()
//        println("\(uid)")
        SocialManager.sharedInstance.getPost(Int(uid), completionHandler: { (result, error) -> Void in
            if let error = error {
                
            } else {
                self.isFinishedGettingUserPosts = true
                if self.isFirstDataLoad {
                    XAppDelegate.dataStore.userPosts = result!
                    self.finishGettingDataInitially()
                } else {
                    self.finishGettingUserPosts(result!)
                }
            }
        })
    }
    
    func getFollowers() {
        SocialManager.sharedInstance.getFollowersProfile { (result, error) -> Void in
            if let error = error {
                
            } else {
                self.isFinishedGettingFollowers = true
                if self.isFirstDataLoad {
                    XAppDelegate.dataStore.followers = result!
                    self.finishGettingDataInitially()
                } else {
                    self.finishGettingFollowers(result!)
                }
            }
        }
    }
    
    func getFollowingUsers() {
//        println("retrieveFollowingUsers")
        SocialManager.sharedInstance.getFollowingUsersProfile { (result, error) -> Void in
            if let error = error {
                
            } else {
                self.isFinishedGettingFollowingUsers = true
                if self.isFirstDataLoad {
                    XAppDelegate.dataStore.followingUsers = result!
                    self.finishGettingDataInitially()
                } else {
                    self.finishGettingFollowingUsers(result!)
                }
            }
        }
    }
    
    func finishGettingDataInitially() {
        if isFirstDataLoad {
            if isFinishedGettingUserPosts && isFinishedGettingFollowers && isFinishedGettingFollowingUsers {
                tableView.reloadData()
                isFirstDataLoad = false
                isFinishedGettingUserPosts = false
                isFinishedGettingFollowers = false
                isFinishedGettingFollowingUsers = false
                Utilities.hideHUD()
            }
        }
    }
    
    func finishGettingUserPosts(userPosts: [UserPost]) {
        reloadDataIfNeeded(&DataStore.sharedInstance.userPosts, newData: userPosts)
        isFinishedGettingUserPosts = false
    }
    
    func finishGettingFollowers(followers: [UserProfile]) {
        reloadDataIfNeeded(&DataStore.sharedInstance.followers, newData: followers)
        isFinishedGettingFollowers = false
    }
    
    func finishGettingFollowingUsers(followingUsers: [UserProfile]) {
        reloadDataIfNeeded(&DataStore.sharedInstance.followingUsers, newData: followingUsers)
        isFinishedGettingFollowingUsers = false
    }
    
    func reloadDataIfNeeded<T: SequenceType>(inout oldData: T, newData: T) {
        if DataStore.sharedInstance.isDataUpdated(oldData, newData: newData) {
            oldData = newData
            tableView.reloadData()
        }
    }
    
    // MARK: - Convenience
    func getDataInitially() {
        Utilities.showHUD()
        // TODO: Delete get user profile if app delegate has user profile already
        getCurrentUserProfile()
        currentTab = .Post
        getUserPosts()
        getFollowers()
        getFollowingUsers()
    }
    
    func tapButton() {
        tableView.reloadData()
//        Utilities.showHUD()
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
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentTab {
        case .Post:
            return XAppDelegate.dataStore.userPosts.count
        case .Followers:
            return XAppDelegate.dataStore.followers.count
        case .Following:
            return XAppDelegate.dataStore.followingUsers.count
        }
    }
    
    func tableView(tableView: ASTableView!, nodeForRowAtIndexPath indexPath: NSIndexPath!) -> ASCellNode! {
        switch currentTab {
        case .Post:
            let post = XAppDelegate.dataStore.userPosts[indexPath.row] as UserPost
            return ProfilePostCellNode(userPost: post)
        case .Followers:
            let follower = XAppDelegate.dataStore.followers[indexPath.row] as UserProfile
            let cell = ProfileFollowCellNode(user: follower, isFollowed: false)
//            cell.delegate
            return cell
        case .Following:
            let followingUser = XAppDelegate.dataStore.followingUsers[indexPath.row] as UserProfile
            return ProfileFollowCellNode(user: followingUser)
        }
    }
    
    func tableView(tableView: UITableView!, heightForHeaderInSection section: Int) -> CGFloat {
        return secondSectionHeaderHeight
    }
    
    func tableView(tableView: UITableView!, viewForHeaderInSection section: Int) -> UIView! {
        if let currentUser = currentUser {
            let view = ProfileSecondSectionHeaderView(frame: CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.width, secondSectionHeaderHeight), userProfile: currentUser, parentViewController: self)
            view.delegate = self
            return view
        }
        return nil
    }
    
    func didTapPostButton() {
        if currentTab != .Post {
            currentTab = .Post
//            reloadButton()
            tapButton()
        }
    }
    
    func didTapFollowersButton() {
        if currentTab != .Followers {
            currentTab = .Followers
//            reloadButton()
            tapButton()
        }
    }
    
    func didTapFollowingButton() {
        if currentTab != .Following {
            currentTab = .Following
//            reloadButton()
            tapButton()
        }
    }
    
    // MARK: - Temporary function
    func getCurrentUserProfile() {
        let uid = XAppDelegate.mobilePlatform.userCred.getUid()
        SocialManager.sharedInstance.getProfile("\(uid)", completionHandler: { (result, error) -> Void in
            if let error = error {
                
            } else {
                if result!.count > 0 {
                    self.currentUser = result![0]
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
