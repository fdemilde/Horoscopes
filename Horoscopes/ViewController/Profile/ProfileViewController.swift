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
    
    var facebookLoginButton: UIButton?
    var facebookLoginLabel: UILabel?
    
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
        var image = Utilities.getImageToSupportSize("background", size: self.view.frame.size, frame: self.view.bounds)
        view.backgroundColor = UIColor(patternImage: image)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "finishLoadingPostDataSource:", name: self.postDataSourceNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "finishLoadingFollowersDataSource:", name: self.followersDataSourceNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "finishLoadingFollowingDataSource:", name: self.followingDataSourceNotification, object: nil)
        
        configureButtons()
        configureProfileTableView()
        view.addSubview(profileTableView!)
        
        if SocialManager.sharedInstance.isLoggedInFacebook() {
            configureUI()
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
            profileTableView!.frame = CGRectMake(padding, postButton.bounds.origin.y + postButton.bounds.height, view.frame.width - padding*2, view.bounds.height - postButton.bounds.height - tabBarHeight)
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
        changeButtonUIWhenClicked(sender)
    }
    
    @IBAction func touchFollowersButton(sender: UIButton) {
        resetProfileTableView()
        changeProfileTableViewToFollow()
        currentTab = .Followers
        reloadFollowersDataSource()
        changeButtonUIWhenClicked(sender)
    }
    
    @IBAction func touchFollowingButton(sender: UIButton) {
        resetProfileTableView()
        changeProfileTableViewToFollow()
        currentTab = .Following
        reloadFollowingDataSource()
        changeButtonUIWhenClicked(sender)
    }
    
    // MARK: ConfigureUI
    
    func configureUI() {
        showButtonsAndTable()
        reloadPostDataSource()
        reloadFollowersDataSource()
        reloadFollowingDataSource()
    }
    
    func configureLoginView() {
        facebookLoginButton = UIButton()
        let facebookLoginImage = UIImage(named: "fb_login_icon")
        facebookLoginButton!.setImage(facebookLoginImage, forState: UIControlState.Normal)
        facebookLoginButton!.sizeToFit()
        facebookLoginButton!.frame.origin = CGPointMake(view.frame.width/2 - facebookLoginButton!.frame.width/2, view.frame.height/2 - facebookLoginButton!.frame.height/2)
        facebookLoginButton!.addTarget(self, action: "loginFacebook:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(facebookLoginButton!)
        facebookLoginLabel = UILabel()
        facebookLoginLabel!.text = "You need to login to Facebook\nto enjoy this feature"
        facebookLoginLabel!.textColor = UIColor.lightTextColor()
        facebookLoginLabel!.numberOfLines = 2
        facebookLoginLabel!.sizeToFit()
        facebookLoginLabel!.textAlignment = NSTextAlignment.Center
        facebookLoginLabel!.frame.origin = CGPointMake(view.frame.width/2 - facebookLoginLabel!.frame.width/2, facebookLoginButton!.frame.origin.y + facebookLoginButton!.frame.size.height + 8)
        view.addSubview(facebookLoginLabel!)
    }
    
    func configureButtons() {
        postButton.titleLabel?.textAlignment = NSTextAlignment.Center
        postButton.titleLabel?.numberOfLines = 2
        postButton.setTitleColor(UIColor.lightTextColor(), forState: UIControlState.Normal)
        followersButton.titleLabel?.numberOfLines = 2
        followersButton.titleLabel?.textAlignment = NSTextAlignment.Center
        followingButton.titleLabel?.numberOfLines = 2
        followingButton.titleLabel?.textAlignment = NSTextAlignment.Center
    }
    
    func showButtonsAndTable() {
        postButton.hidden = false
        postButton.enabled = true
        followersButton.hidden = false
        followersButton.enabled = true
        followingButton.hidden = false
        followingButton.enabled = true
        profileTableView?.hidden = false
    }
    
    func configureProfileTableView() {
        profileTableView = ASTableView(frame: CGRectZero, style: UITableViewStyle.Plain)
        profileTableView?.hidden = true
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
    
    func changeButtonUIWhenClicked(sender: UIButton) {
        sender.setTitleColor(UIColor.lightTextColor(), forState: UIControlState.Normal)
        let buttons = [postButton, followersButton, followingButton]
        for button in buttons {
            if button != sender {
                button.setTitleColor(UIColor.darkTextColor(), forState: UIControlState.Normal)
//                button.setTitleColor(UIColor(red: 46/255.0, green: 52/255.0, blue: 83/255.0, alpha: 1), forState: UIControlState.Normal)
            }
        }
    }
    
    func resetProfileTableView() {
        clearTable = true
        profileTableView?.reloadData()
        clearTable = false
    }
    
    // MARK: Helper
    func loginFacebook(sender: UIButton) {
        SocialManager.sharedInstance.loginFacebook { (result, error) -> () in
            if let error = error {
                // Show alert. This has been done by the calling method.
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.facebookLoginButton?.removeFromSuperview()
                    self.facebookLoginLabel?.removeFromSuperview()
                    self.configureUI()
                })
            }
        }
    }
    
    func finishLoadingPostDataSource(notification: NSNotification) {
        isFinishedPostDataSource = true
        if isFirstDataLoad {
            loadDataInitially()
        } else {
            isFinishedPostDataSource = false
            postButton.setTitle("Post\n\(self.userPosts.count)", forState: UIControlState.Normal)
            profileTableView?.reloadData()
            Utilities.hideHUD()
        }
    }
    
    func finishLoadingFollowersDataSource(notification: NSNotification) {
        isFinishedFollowersDataSource = true
        if isFirstDataLoad {
            loadDataInitially()
        } else {
            isFinishedFollowersDataSource = false
            followersButton.setTitle("Followers\n\(self.followers.count)", forState: UIControlState.Normal)
            profileTableView?.reloadData()
            Utilities.hideHUD()
        }
    }
    
    func finishLoadingFollowingDataSource(notification: NSNotification) {
        isFinishedFollowingDataSource = true
        if isFirstDataLoad {
            loadDataInitially()
        } else {
            isFinishedFollowingDataSource = false
            followingButton.setTitle("Following\n\(self.followingUsers.count)", forState: UIControlState.Normal)
            profileTableView?.reloadData()
            Utilities.hideHUD()
        }
    }
    
    func loadDataInitially() {
        if isFinishedPostDataSource && isFinishedFollowersDataSource && isFinishedFollowingDataSource {
            isFirstDataLoad = false
            postButton.setTitle("Post\n\(self.userPosts.count)", forState: UIControlState.Normal)
            followersButton.setTitle("Followers\n\(self.followers.count)", forState: UIControlState.Normal)
            followingButton.setTitle("Following\n\(self.followingUsers.count)", forState: UIControlState.Normal)
            profileTableView?.reloadData()
            populateIsFollowedArray()
            Utilities.hideHUD()
        }
    }
    
    func reloadPostDataSource() {
        Utilities.showHUD()
        if SocialManager.sharedInstance.isLoggedInZwigglers() {
            let uid = XAppDelegate.mobilePlatform.userCred.getUid()
            userPosts.removeAll(keepCapacity: false)
            SocialManager.sharedInstance.getPost(Int(uid), completionHandler: { (result, error) -> Void in
                if let error = error {
                    NSLog("Cannot load user's posts. Error: \(error)")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        NSNotificationCenter.defaultCenter().postNotificationName(self.postDataSourceNotification, object: nil)
                    })
                } else {
                    let users = result!["users"] as! Dictionary<String, AnyObject>
                    let posts = result!["posts"] as? Array<AnyObject>
                    if let posts = result!["posts"] as? Array<AnyObject> {
                        for post in posts {
                            let userPost = UserPost(data: post as! NSDictionary)
                            userPost.user = UserProfile(data: users["\(uid)"] as! NSDictionary)
                            self.userPosts.append(userPost)
                        }
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            NSNotificationCenter.defaultCenter().postNotificationName(self.postDataSourceNotification, object: self.userPosts)
                        })
                    }
                }
            })
        } else {
            SocialManager.sharedInstance.loginZwigglers(FBSDKAccessToken.currentAccessToken().tokenString, completionHandler: { (responseDict, error) -> Void in
                if let error = error {
                    NSLog("Cannot load user's posts. Error: \(error)")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        NSNotificationCenter.defaultCenter().postNotificationName(self.postDataSourceNotification, object: nil)
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.reloadPostDataSource()
                    })
                }
            })
        }
    }
    
    func reloadFollowersDataSource() {
        Utilities.showHUD()
        followers.removeAll(keepCapacity: false)
        SocialManager.sharedInstance.getFollowers({ (result, error) -> () in
            if let error = error {
                NSLog("Cannot get followers. Error: \(error)")
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    NSNotificationCenter.defaultCenter().postNotificationName(self.followersDataSourceNotification, object: nil)
                })
            } else {
                if let followersId = result!["followers"] as? Array<Int> {
                    let followersIdString = followersId.map({"\($0)"})
                    SocialManager.sharedInstance.getProfile(usersIdSeparatedByComma: ",".join(followersIdString), completionHandler: { (result, error) -> Void in
                        if let error = error {
                            NSLog("Cannot get followers. Error: \(error)")
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                NSNotificationCenter.defaultCenter().postNotificationName(self.followersDataSourceNotification, object: nil)
                            })
                        } else {
                            for id in followersId {
                                if let users = result!["result"] as? Dictionary<String, AnyObject> {
                                    let userProfile = UserProfile(data: users[String(id)] as! NSDictionary)
                                    self.followers.append(userProfile)
                                }
                            }
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                NSNotificationCenter.defaultCenter().postNotificationName(self.followersDataSourceNotification, object: self.followers)
                            })
                        }
                    })
                }
            }
        })
    }
    
    func reloadFollowingDataSource() {
        Utilities.showHUD()
        followingUsers.removeAll(keepCapacity: false)
        SocialManager.sharedInstance.getFollowing({ (result, error) -> () in
            if let error = error {
                NSLog("Cannot get following users. Error: \(error)")
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    NSNotificationCenter.defaultCenter().postNotificationName(self.followingDataSourceNotification, object: nil)
                })
            } else {
                if let followingUsersId = result!["following"] as? Array<Int> {
                    let followingUsersIdString = followingUsersId.map({"\($0)"})
                    SocialManager.sharedInstance.getProfile(usersIdSeparatedByComma: ",".join(followingUsersIdString), completionHandler: { (result, error) -> Void in
                        if let error = error {
                            NSLog("Cannot get profile. Error: \(error)")
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                NSNotificationCenter.defaultCenter().postNotificationName(self.followingDataSourceNotification, object: nil)
                            })
                        } else {
                            for id in followingUsersId {
                                if let users = result!["result"] as? Dictionary<String, AnyObject> {
                                    let userProfile = UserProfile(data: users[String(id)] as! NSDictionary)
                                    self.followingUsers.append(userProfile)
                                }
                            }
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                NSNotificationCenter.defaultCenter().postNotificationName(self.followingDataSourceNotification, object: self.followingUsers)
                            })
                        }
                    })
                }
            }
        })
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
