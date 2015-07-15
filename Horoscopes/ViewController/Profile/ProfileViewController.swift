//
//  ProfileViewController.swift
//  Horoscopes
//
//  Created by Dang Doan on 7/9/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, ASTableViewDataSource, ASTableViewDelegate {
    
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var followersButton: UIButton!
    @IBOutlet weak var followingButton: UIButton!
    
    var profileTableView: ASTableView?
    let padding: CGFloat = 10
    let tabBarHeight: CGFloat = 49
    
    var userPosts = [UserPost]()
    enum Tab {
        case Post
        case Followers
        case Following
    }
    var followingUsers = [UserProfile]()
    var followers = [UserProfile]()
    var isFollowedArray = [Bool]()
    var currentTab = Tab.Post
    var userId: NSNumber!
    
    var clearTable = false
    
    let postDataSourceNotification = "Finish reloading post data source"
    let followersDataSourceNotification = "Finish reloading followers data source"
    let followingDataSourceNotification = "Finish reloading following data source"
    
    var isFinishedPostDataSource = false
    var isFinishedFollowersDataSource = false
    var isFinishedFollowingDataSource = false
    
    var isFirstDataLoad = true

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        userId = getUserId()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadData:", name: self.postDataSourceNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadData:", name: self.followersDataSourceNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadData:", name: self.followingDataSourceNotification, object: nil)
        
        if userId != -1 {
            configureButtons()
            configureProfileTableView()
            view.addSubview(profileTableView!)
            
            reloadPostDataSource()
            reloadFollowersDataSource()
            reloadFollowingDataSource()
        } else {
            configureLoginView()
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: self.postDataSourceNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: self.followersDataSourceNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: self.followingDataSourceNotification, object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        if profileTableView != nil {
            profileTableView!.frame = CGRectMake(padding, postButton.bounds.height, view.frame.width - padding*2, view.bounds.height - postButton.bounds.height - tabBarHeight)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Action
    @IBAction func touchPostButton(sender: UIButton) {
        resetProfileTableView()
        changeProfileTableViewToPost()
        currentTab = .Post
        reloadPostDataSource()
    }
    
    @IBAction func touchFollowersButton(sender: UIButton) {
        resetProfileTableView()
        changeProfileTableViewToFollow()
        currentTab = .Followers
        reloadFollowersDataSource()
    }
    
    @IBAction func touchFollowingButton(sender: UIButton) {
        resetProfileTableView()
        changeProfileTableViewToFollow()
        currentTab = .Following
        reloadFollowingDataSource()
    }
    
    // MARK: ConfigureUI
    
    func configureLoginView() {
        let facebookLoginButton = UIButton()
        let facebookLoginImage = UIImage(named: "fb_login_icon")
        facebookLoginButton.setImage(facebookLoginImage, forState: UIControlState.Normal)
        facebookLoginButton.sizeToFit()
        facebookLoginButton.frame.origin = CGPointMake(view.frame.width/2 - facebookLoginButton.frame.width/2, view.frame.height/2 - facebookLoginButton.frame.height/2)
        view.addSubview(facebookLoginButton)
        let facebookLoginLabel = UILabel()
        facebookLoginLabel.text = "You need to login to Facebook\nto enjoy this feature"
        facebookLoginLabel.textColor = UIColor.lightTextColor()
        facebookLoginLabel.numberOfLines = 2
        facebookLoginLabel.sizeToFit()
        facebookLoginLabel.textAlignment = NSTextAlignment.Center
        facebookLoginLabel.frame.origin = CGPointMake(view.frame.width/2 - facebookLoginLabel.frame.width/2, facebookLoginButton.frame.origin.y + facebookLoginButton.frame.size.height + 8)
        view.addSubview(facebookLoginLabel)
    }
    
    func configureButtons() {
        postButton.titleLabel?.numberOfLines = 2
        postButton.hidden = false
        followersButton.titleLabel?.numberOfLines = 2
        followersButton.hidden = false
        followingButton.titleLabel?.numberOfLines = 2
        followingButton.hidden = false
    }
    
    func configureProfileTableView() {
        profileTableView = ASTableView(frame: CGRectZero, style: UITableViewStyle.Plain)
        profileTableView!.asyncDataSource = self
        profileTableView!.asyncDelegate = self
        profileTableView!.showsHorizontalScrollIndicator = false
        profileTableView!.showsVerticalScrollIndicator = false
        profileTableView?.layer.cornerRadius = 10
        profileTableView?.layer.masksToBounds = true
        profileTableView?.separatorColor = UIColor.lightGrayColor()
        profileTableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        profileTableView!.backgroundColor = UIColor.clearColor()
    }
    
    func changeProfileTableViewToPost() {
        if currentTab != .Post {
            profileTableView!.separatorStyle = UITableViewCellSeparatorStyle.None
            profileTableView!.backgroundColor = UIColor.clearColor()
        }
    }
    
    func changeProfileTableViewToFollow() {
        if currentTab == .Post {
            profileTableView?.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            profileTableView?.backgroundColor = UIColor.whiteColor()
        }
    }
    
    func resetProfileTableView() {
        clearTable = true
        profileTableView?.reloadData()
        clearTable = false
    }
    
    // MARK: Helper
    func getUserId() -> NSNumber {
        if XAppDelegate.mobilePlatform.userCred.hasToken() {
            return XAppDelegate.mobilePlatform.userCred.getUid()
        } else {
            return -1
        }
    }
    
    func reloadPostDataSource() {
        Utilities.showHUD()
        if userId != -1 {
            userPosts.removeAll(keepCapacity: false)
            SocialManager.sharedInstance.getPost(Int(userId), completionHandler: { (result, error) -> Void in
                if let error = error {
                    NSLog("Cannot load user's posts. Error: \(error)")
                } else {
                    let users = result!["users"] as! Dictionary<String, AnyObject>
                    if let posts = result!["posts"] as? Array<AnyObject> {
                        for post in posts {
                            let userPost = UserPost(data: post as! NSDictionary)
                            userPost.user = UserProfile(data: users["\(self.userId)"] as! NSDictionary)
                            self.userPosts.append(userPost)
                        }
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            if !self.isFirstDataLoad {
                                self.postButton.setTitle("Post\n\(self.userPosts.count)", forState: UIControlState.Normal)
                            }
                            self.isFinishedPostDataSource = true
                            NSNotificationCenter.defaultCenter().postNotificationName(self.postDataSourceNotification, object: nil)
                        })
                    }
                }
            })
        }
    }
    
    func reloadFollowersDataSource() {
        Utilities.showHUD()
        if userId != -1 {
            followers.removeAll(keepCapacity: false)
            SocialManager.sharedInstance.getFollowers({ (result, error) -> () in
                if let error = error {
                    NSLog("Cannot get followers. Error: \(error)")
                } else {
                    if let followersId = result!["followers"] as? Array<Int> {
                        let followersIdString = followersId.map({"\($0)"})
                        SocialManager.sharedInstance.getProfile(usersIdSeparatedByComma: ",".join(followersIdString), completionHandler: { (result, error) -> Void in
                            if let error = error {
                                NSLog("Cannot get followers. Error: \(error)")
                            } else {
                                for id in followersId {
                                    if let users = result!["result"] as? Dictionary<String, AnyObject> {
                                        let userProfile = UserProfile(data: users[String(id)] as! NSDictionary)
                                        self.followers.append(userProfile)
                                    }
                                }
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    if !self.isFirstDataLoad {
                                        self.followersButton.setTitle("Followers\n\(self.followers.count)", forState: UIControlState.Normal)
                                    }
                                    self.isFinishedFollowersDataSource = true
                                    NSNotificationCenter.defaultCenter().postNotificationName(self.followersDataSourceNotification, object: nil)
                                })
                            }
                        })
                    }
                }
            })
        }
    }
    
    func reloadFollowingDataSource() {
        Utilities.showHUD()
        if userId != -1 {
            followingUsers.removeAll(keepCapacity: false)
            SocialManager.sharedInstance.getFollowing({ (result, error) -> () in
                if let error = error {
                    NSLog("Cannot get following users. Error: \(error)")
                } else {
                    if let followingUsersId = result!["following"] as? Array<Int> {
                        let followingUsersIdString = followingUsersId.map({"\($0)"})
                        SocialManager.sharedInstance.getProfile(usersIdSeparatedByComma: ",".join(followingUsersIdString), completionHandler: { (result, error) -> Void in
                            if let error = error {
                                NSLog("Cannot get profile. Error: \(error)")
                            } else {
                                for id in followingUsersId {
                                    if let users = result!["result"] as? Dictionary<String, AnyObject> {
                                        let userProfile = UserProfile(data: users[String(id)] as! NSDictionary)
                                        self.followingUsers.append(userProfile)
                                    }
                                }
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    if !self.isFirstDataLoad {
                                        self.followingButton.setTitle("Following\n\(self.followingUsers.count)", forState: UIControlState.Normal)
                                    }
                                    self.isFinishedFollowingDataSource = true
                                    NSNotificationCenter.defaultCenter().postNotificationName(self.followingDataSourceNotification, object: nil)
                                })
                            }
                        })
                    }
                }
            })
        }
    }
    
    func reloadData(notification: NSNotification) {
        if isFirstDataLoad {
            if isFinishedPostDataSource && isFinishedFollowersDataSource && isFinishedFollowingDataSource {
                profileTableView?.reloadData()
                populateIsFollowedArray()
                self.postButton.setTitle("Post\n\(self.userPosts.count)", forState: UIControlState.Normal)
                self.followersButton.setTitle("Followers\n\(self.followers.count)", forState: UIControlState.Normal)
                self.followingButton.setTitle("Following\n\(self.followingUsers.count)", forState: UIControlState.Normal)
                isFirstDataLoad = false
                isFinishedPostDataSource = false
                isFinishedFollowersDataSource = false
                isFinishedFollowingDataSource = false
                Utilities.hideHUD()
            }
        } else {
            profileTableView?.reloadData()
            isFinishedPostDataSource = false
            isFinishedFollowersDataSource = false
            isFinishedFollowingDataSource = false
            Utilities.hideHUD()
        }
    }
    
    func populateIsFollowedArray() {
        isFollowedArray.removeAll(keepCapacity: true)
        for follower in followers {
            var isFollowed = false
            for followingUser in followingUsers {
                if follower.uid == followingUser.uid {
                    isFollowed = true
                    break
                }
            }
            isFollowedArray.append(isFollowed)
        }
    }
    
    // MARK: Datasource and delegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if clearTable {
            return 0
        } else {
            switch currentTab {
            case .Followers:
                return followers.count
            case .Following:
                return followingUsers.count
            default:
                return userPosts.count
            }
        }
    }
    
    func tableView(tableView: ASTableView!, nodeForRowAtIndexPath indexPath: NSIndexPath!) -> ASCellNode! {
        let cell: ProfileCellNode
        switch currentTab {
        case .Followers:
            let follower = followers[indexPath.row] as UserProfile
            cell = ProfileCellNode(follower: follower, isFollowed: isFollowedArray[indexPath.row])
        case .Following:
            let followingUser = followingUsers[indexPath.row] as UserProfile
            cell = ProfileCellNode(followingUser: followingUser)
        default:
            let userPost = userPosts[indexPath.row] as UserPost
            cell = ProfileCellNode(userPost: userPost)
        }
        return cell
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
