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

class ProfileViewController: MyViewController, ASTableViewDataSource, ASTableViewDelegate, ProfileTabDelegate {
    
    var profileType: ProfileType!
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
    let firstSectionHeaderHeight: CGFloat = 54
    let firstSectionCellHeight: CGFloat = 233
    let secondSectionHeaderHeight: CGFloat = 80
    let secondSectionHeaderTag = 1
    var userProfile: UserProfile!
    var userPosts: [UserPost]!
    
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
        // TODO: Comment this code when finish refactoring
        profileType = .CurrentUser
        configureUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
//        println("viewWillLayoutSubviews")
        tableView.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y + ADMOD_HEIGHT, view.frame.width, view.frame.height - ADMOD_HEIGHT - TABBAR_HEIGHT)
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
        if profileType == .CurrentUser {
            if SocialManager.sharedInstance.isLoggedInZwigglers() {
                userProfile = XAppDelegate.currentUser
                getDataInitially()
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
//        println("configureLoginView")
//        let headerFrame = CGRectMake(view.bounds.origin.x, view.bounds.origin.y + ADMOD_HEIGHT, view.bounds.width, view.bounds.height - ADMOD_HEIGHT)
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
        SocialManager.sharedInstance.login { (error) -> Void in
            if let error = error {
                
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.tableHeaderView = nil
                    self.userProfile = XAppDelegate.currentUser
                    self.getDataInitially()
                })
            }
        }
    }
    
    // MARK: - Helper
    func getUserPosts() {
//        let uid = userProfile.uid
//        println("\(uid)")
        SocialManager.sharedInstance.getPost(userProfile.uid, completionHandler: { (result, error) -> Void in
            if let error = error {
                
            } else {
                self.isFinishedGettingUserPosts = true
                if self.isFirstDataLoad {
                    DataStore.sharedInstance.userPosts = result!
                    self.finishGettingDataInitially()
                } else {
                    self.finishGettingUserPosts(result!)
                }
            }
        })
    }
    
    func getFollowers() {
        SocialManager.sharedInstance.getCurrentUserFollowersProfile { (result, error) -> Void in
            if let error = error {
                
            } else {
                self.isFinishedGettingFollowers = true
                if self.isFirstDataLoad {
                    DataStore.sharedInstance.followers = result!
                    self.finishGettingDataInitially()
                } else {
                    self.finishGettingFollowers(result!)
                }
            }
        }
    }
    
    func getFollowingUsers() {
//        println("retrieveFollowingUsers")
        SocialManager.sharedInstance.getCurrentUserFollowingProfile { (result, error) -> Void in
            if let error = error {
                
            } else {
                self.isFinishedGettingFollowingUsers = true
                if self.isFirstDataLoad {
                    DataStore.sharedInstance.followingUsers = result!
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
                tableView.hidden = false
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
    
    // MARK: - Convenience
    func getDataInitially() {
        Utilities.showHUD()
        tableView.hidden = true
        currentTab = .Post
        getUserPosts()
        getFollowers()
        getFollowingUsers()
    }
    
    func reloadDataIfNeeded<T: SequenceType>(inout oldData: T, newData: T) {
        if DataStore.sharedInstance.isDataUpdated(oldData, newData: newData) {
            oldData = newData
            reloadSection(1)
        }
    }
    
    func reloadSection(section: Int) {
        let range = NSMakeRange(section, 1)
        let section = NSIndexSet(indexesInRange: range)
        tableView?.reloadSections(section, withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    func tapButton() {
        reloadButton()
        reloadSection(1)
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
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        switch currentTab {
        case .Post:
            return DataStore.sharedInstance.userPosts.count
        case .Followers:
            return DataStore.sharedInstance.followers.count
        case .Following:
            return DataStore.sharedInstance.followingUsers.count
        }
    }
    
    func tableView(tableView: ASTableView!, nodeForRowAtIndexPath indexPath: NSIndexPath!) -> ASCellNode! {
        if indexPath.section == 0 {
            if profileType == .CurrentUser {
                if XAppDelegate.currentUser?.uid != -1 {
                    let cell = ProfileFirstSectionCellNode(userProfile: XAppDelegate.currentUser!)
                    return cell
                }
            } else {
                
            }
            
            return ASCellNode()
        } else {
            switch currentTab {
            case .Post:
                let post = DataStore.sharedInstance.userPosts[indexPath.row] as UserPost
                return PostCellNode(post: post, type: .Profile)
            case .Followers:
                let follower = DataStore.sharedInstance.followers[indexPath.row] as UserProfile
                let cell = ProfileFollowCellNode(user: follower, isFollowed: false)
                //            cell.delegate
                return cell
            case .Following:
                let followingUser = DataStore.sharedInstance.followingUsers[indexPath.row] as UserProfile
                return ProfileFollowCellNode(user: followingUser)
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
        if XAppDelegate.currentUser?.uid != -1 {
            let view = ProfileSecondSectionHeaderView(frame: CGRectMake(tableView.frame.origin.x, firstSectionHeaderHeight + firstSectionCellHeight, tableView.frame.width, secondSectionHeaderHeight), userProfile: XAppDelegate.currentUser!, parentViewController: self)
            view.delegate = self
            view.tag = secondSectionHeaderTag
            return view
        }
        return nil
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
