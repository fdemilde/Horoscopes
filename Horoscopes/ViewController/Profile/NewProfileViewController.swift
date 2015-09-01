//
//  NewProfileViewController.swift
//  Horoscopes
//
//  Created by Dang Doan on 8/26/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

class NewProfileViewController: ViewControllerWithAds, UITableViewDataSource, UITableViewDelegate, PostTableViewCellDelegate, FollowTableViewCellDelegate {

    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var horoscopeSignView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var horoscopeSignImageView: UIImageView!
    @IBOutlet weak var horoscopeSignLabel: UILabel!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var followersButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewLeadingSpaceLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTrailingSpaceLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewBottomSpaceLayoutConstraint: NSLayoutConstraint!
    
    var loginView: UIView!
    
    enum ProfileType {
        case CurrentUser
        case OtherUser
    }
    enum Tab {
        case Post
        case Followers
        case Following
    }
    var profileType: ProfileType = .CurrentUser
    var userProfile = UserProfile()
    var userPosts = [UserPost]()
    var followers = [UserProfile]()
    var followingUsers = [UserProfile]()
    var currentTab = Tab.Post
    static let postDateFormat = "MMMM dd, yyyy"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let backgroundImage = Utilities.getImageToSupportSize("background", size: view.frame.size, frame: view.bounds)
        view.backgroundColor = UIColor(patternImage: backgroundImage)
        if profileType == .CurrentUser {
            if SocialManager.sharedInstance.isLoggedInFacebook() {
                if SocialManager.sharedInstance.isLoggedInZwigglers() {
                    getProfileAndData()
                } else {
                    SocialManager.sharedInstance.loginZwigglers(FBSDKAccessToken.currentAccessToken().tokenString, completionHandler: { (responseDict, error) -> Void in
                        if let error = error {
                            Utilities.showAlert(self, title: "Server Error", message: "There is an error on server. Please try again later.", error: error)
                        } else {
                            self.getProfileAndData()
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Configure UI
    
    func configureProfileView() {
        Utilities.getImageFromUrlString(userProfile.imgURL, completionHandler: { (image) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.profileImageView.image = image
                self.profileImageView.layer.cornerRadius = 60 / 2
                self.profileImageView.clipsToBounds = true
            })
        })
        profileLabel.text = userProfile.name
        horoscopeSignLabel.text = userProfile.horoscopeSignString
        horoscopeSignImageView.image = userProfile.horoscopeSignImage
    }
    
    func updateTableView() {
        if currentTab != .Post {
            if tableViewLeadingSpaceLayoutConstraint.constant == 0 {
                tableViewLeadingSpaceLayoutConstraint.constant = 10
                tableViewTrailingSpaceLayoutConstraint.constant = 10
                tableViewBottomSpaceLayoutConstraint.constant = 8
                tableView.clipsToBounds = true
                tableView.backgroundColor = UIColor.whiteColor()
                tableView.separatorStyle = .SingleLine
            }
        } else {
            if tableViewLeadingSpaceLayoutConstraint.constant != 0 {
                tableViewLeadingSpaceLayoutConstraint.constant = 0
                tableViewTrailingSpaceLayoutConstraint.constant = 0
                tableViewBottomSpaceLayoutConstraint.constant = 0
                tableView.clipsToBounds = false
                tableView.backgroundColor = UIColor.clearColor()
                tableView.separatorStyle = .None
            }
        }
    }
    
    func configureTabButton() {
        postButton.titleLabel?.textAlignment = NSTextAlignment.Center
        followersButton.titleLabel?.textAlignment = NSTextAlignment.Center
        followingButton.titleLabel?.textAlignment = NSTextAlignment.Center
    }
    
    func configureTableView() {
        tableView.estimatedRowHeight = 300
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.layer.cornerRadius = 4
        horoscopeSignView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        horoscopeSignView.layer.cornerRadius = 4
        horoscopeSignView.clipsToBounds = true
    }
    
    func configureLoginView() {
        tableHeaderView.hidden = true
        
        let loginFrame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y + ADMOD_HEIGHT, width: view.frame.width, height: view.frame.height - ADMOD_HEIGHT - TABBAR_HEIGHT)
        loginView = UIView(frame: loginFrame)
        let padding: CGFloat = 8
        
        let facebookLoginButton = UIButton()
        let facebookLoginImage = UIImage(named: "fb_login_icon")
        facebookLoginButton.setImage(facebookLoginImage, forState: UIControlState.Normal)
        facebookLoginButton.sizeToFit()
        facebookLoginButton.frame = CGRectMake(loginFrame.width/2 - facebookLoginButton.frame.width/2, loginFrame.height/2 - facebookLoginButton.frame.height/2, facebookLoginButton.frame.width, facebookLoginButton.frame.height)
        facebookLoginButton.addTarget(self, action: "login:", forControlEvents: UIControlEvents.TouchUpInside)
        loginView.addSubview(facebookLoginButton)
        
        let facebookLoginLabel = UILabel()
        facebookLoginLabel.text = "You need to login to Facebook\nto enjoy this feature"
        facebookLoginLabel.textColor = UIColor.lightTextColor()
        facebookLoginLabel.numberOfLines = 2
        facebookLoginLabel.sizeToFit()
        facebookLoginLabel.textAlignment = NSTextAlignment.Center
        facebookLoginLabel.frame = CGRectMake(loginFrame.width/2 - facebookLoginLabel.frame.width/2, facebookLoginButton.frame.origin.y + facebookLoginButton.frame.height + padding, facebookLoginLabel.frame.width, facebookLoginLabel.frame.height)
        loginView.addSubview(facebookLoginLabel)
        
        view.addSubview(loginView)
    }
    
    func configurePostTableViewCell(cell: PostTableViewCell, post: UserPost) {
        switch post.type {
        case .OnYourMind:
            cell.headerView.backgroundColor = UIColor.newsfeedMindColor()
            cell.postTypeImageView.image = UIImage(named: "post_type_mind")
        case .Feeling:
            cell.headerView.backgroundColor = UIColor.newsfeedFeelColor()
            cell.postTypeImageView.image = UIImage(named: "post_type_feel")
        case .Story:
            cell.headerView.backgroundColor = UIColor.newsfeedStoryColor()
            cell.postTypeImageView.image = UIImage(named: "post_type_story")
        }
        cell.postDateLabel.text = Utilities.getDateStringFromTimestamp(NSTimeInterval(post.ts), dateFormat: NewProfileViewController.postDateFormat)
        cell.textView.text = post.message
    }
    
    func configureFollowTableViewCell(cell: FollowTableViewCell, profile: UserProfile) {
        cell.nameLabel.text = profile.name
        cell.horoscopeSignLabel.text = profile.horoscopeSignString
        Utilities.getImageFromUrlString(profile.imgURL, completionHandler: { (image) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                cell.profileImageView?.image = image
            })
        })
    }
    
    // MARK: - Action
    
    @IBAction func tapPostButton(sender: UIButton) {
        currentTab = .Post
        updateTabButton(sender)
        updateTableView()
        tableView.reloadData()
    }
    
    @IBAction func tapFollowingButton(sender: UIButton) {
        currentTab = .Following
        updateTabButton(sender)
        updateTableView()
        tableView.reloadData()
    }
    
    @IBAction func tapFollowersButton(sender: UIButton) {
        currentTab = .Followers
        updateTabButton(sender)
        updateTableView()
        tableView.reloadData()
    }
    
    func login(sender: UIButton) {
        Utilities.showHUD()
        SocialManager.sharedInstance.login { (error, permissionGranted) -> Void in
            if let error = error {
                Utilities.showAlert(self, title: "Log In Error", message: "Could not log in to Facebook. Please try again later.", error: error)
            } else {
                if permissionGranted {
                    self.getProfileAndData()
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.loginView.removeFromSuperview()
                        self.tableHeaderView.hidden = false
                        self.tableView.hidden = false
                    })
                } else {
                    Utilities.showAlert(self, title: "Permission Denied", message: "Not enough permission is granted.", error: nil)
                }
            }
        }
    }
    
    // MARK: - Data handler
    
    func profileOfCurrentUser() -> UserProfile? {
        var result: UserProfile?
        if XAppDelegate.currentUser.uid == -1 {
            SocialManager.sharedInstance.persistUserProfile({ (error) -> Void in
                if let error = error {
                    Utilities.showAlert(self, title: "Server Error", message: "There is an error on server. Please try again later.", error: error)
                } else {
                    result = XAppDelegate.currentUser
                }
            })
        } else {
            result = XAppDelegate.currentUser
        }
        return result
    }
    
    func getDataInitially() {
        Utilities.showHUD()
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.configureProfileView()
            self.configureTabButton()
            self.configureTableView()
            var getDataGroup = dispatch_group_create()
            
            self.getUserPosts(getDataGroup)
            self.getFollowers(getDataGroup)
            self.getFollowingUsers(getDataGroup)
            
            dispatch_group_notify(getDataGroup, dispatch_get_main_queue()) { () -> Void in
                self.checkFollowStatus()
                self.setTabButtonTitleLabel(self.postButton)
                self.setTabButtonTitleLabel(self.followingButton)
                self.setTabButtonTitleLabel(self.followersButton)
                self.tableView.reloadData()
                Utilities.hideHUD()
            }
        })
    }
    
    func getUserPosts(dispatchGroup: dispatch_group_t?) {
        if let group = dispatchGroup {
            dispatch_group_enter(group)
        }
        SocialManager.sharedInstance.getPost(userProfile.uid, completionHandler: { (result, error) -> Void in
            if let error = error {
                
            } else {
                self.userPosts = result!
            }
            if let group = dispatchGroup {
                dispatch_group_leave(group)
            }
        })
    }
    
    func getFollowers(dispatchGroup: dispatch_group_t?) {
        if let group = dispatchGroup {
            dispatch_group_enter(group)
        }
        if profileType == .CurrentUser {
            SocialManager.sharedInstance.getCurrentUserFollowersProfile { (result, error) -> Void in
                if let error = error {
                    
                } else {
                    self.followers = result!
                }
                if let group = dispatchGroup {
                    dispatch_group_leave(group)
                }
            }
        } else {
            SocialManager.sharedInstance.getOtherUserFollowersProfile(userProfile.uid, completionHandler: { (result, error) -> Void in
                if let error = error {
                    
                } else {
                    self.followers = result!
                }
                if let group = dispatchGroup {
                    dispatch_group_leave(group)
                }
            })
        }
    }
    
    func getFollowingUsers(dispatchGroup: dispatch_group_t?) {
        if let group = dispatchGroup {
            dispatch_group_enter(group)
        }
        if profileType == .CurrentUser {
            SocialManager.sharedInstance.getCurrentUserFollowingProfile { (result, error) -> Void in
                if let error = error {
                    
                } else {
                    self.followingUsers = result!
                }
                if let group = dispatchGroup {
                    dispatch_group_leave(group)
                }
            }
        } else {
            SocialManager.sharedInstance.getOtherUserFollowingProfile(userProfile.uid, completionHandler: { (result, error) -> Void in
                if let error = error {
                    
                } else {
                    self.followingUsers = result!
                }
                if let group = dispatchGroup {
                    dispatch_group_leave(group)
                }
            })
        }
    }
    
    // MARK: - Helper
    
    func checkFollowStatus() {
        for follower in followers {
            for followingUser in followingUsers {
                if followingUser.uid == follower.uid {
                    follower.isFollowed = true
                    break
                }
            }
        }
    }
    
    func highlightTabButton(sender: UIButton) {
        for button in [postButton, followersButton, followingButton] {
            if button == sender {
                button.alpha = 1
            } else {
                button.alpha = 0.5
            }
        }
    }
    
    func setTabButtonTitleLabel(sender: UIButton) {
        if sender == postButton {
            postButton.setTitle("Post\n\(userPosts.count)", forState: .Normal)
        } else if sender == followingButton {
            followingButton.titleLabel?.text = "Following\n\(followingUsers.count)"
            followingButton.setTitle("Following\n\(followingUsers.count)", forState: .Normal)
        } else {
            followersButton.titleLabel?.text = "Followers\n\(followers.count)"
            followersButton.setTitle("Followers\n\(followers.count)", forState: .Normal)
        }
    }
    
    func getProfileAndData() {
        if let profile = profileOfCurrentUser() {
            userProfile = profile
            getDataInitially()
        } else {
            let uid = XAppDelegate.mobilePlatform.userCred.getUid()
            SocialManager.sharedInstance.getProfile("\(uid)", completionHandler: { (result, error) -> Void in
                if let error = error {
                    // TODO: Try getting user profile again
                } else {
                    self.userProfile = result![0]
                    self.getDataInitially()
                }
            })
        }
    }
    
    // MARK: - Convenience
    
    func updateTabButton(button: UIButton) {
        highlightTabButton(button)
        setTabButtonTitleLabel(button)
    }
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentTab {
        case .Post:
            return userPosts.count
        case .Followers:
            return followers.count
        case .Following:
            return followingUsers.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if currentTab == .Post {
            let post = userPosts[indexPath.row]
            let cell = tableView.dequeueReusableCellWithIdentifier("PostTableViewCell", forIndexPath: indexPath) as! PostTableViewCell
            cell.type = PostCellType.Profile
            configurePostTableViewCell(cell, post: post)
            cell.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("FollowTableViewCell", forIndexPath: indexPath) as! FollowTableViewCell
            var profile: UserProfile!
            if currentTab == .Following {
                profile = followingUsers[indexPath.row]
                cell.configureFollowButton(profile.isFollowed, isFollowerCell: false)
            } else {
                profile = followers[indexPath.row]
                cell.delegate = self
                cell.configureFollowButton(profile.isFollowed, isFollowerCell: true)
            }
            configureFollowTableViewCell(cell, profile: profile)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if currentTab != .Post {
            return 70
        }
        return UITableViewAutomaticDimension
    }
    
    // MARK: - Delegate
    
    func didTapShareButton(profileName: String?, postContent: String) {
        let name = userProfile.name
        let sharingText = String(format: "%@ \n %@", name, postContent)
        let controller = Utilities.shareViewControllerForType(ShareViewType.ShareViewTypeHybrid, shareType: ShareType.ShareTypeNewsfeed, sharingText: sharingText)
        Utilities.presentShareFormSheetController(self, shareViewController: controller)
    }
    
    func didTapFollowButton(cell: FollowTableViewCell) {
        let index = tableView.indexPathForCell(cell)?.row
        let uid = followers[index!].uid
        Utilities.showHUD()
        SocialManager.sharedInstance.follow(uid, completionHandler: { (error) -> Void in
            if let error = error {
                
            } else {
                let getDataGroup = dispatch_group_create()
                self.getFollowingUsers(getDataGroup)
                dispatch_group_notify(getDataGroup, dispatch_get_main_queue(), { () -> Void in
                    self.checkFollowStatus()
                    self.setTabButtonTitleLabel(self.followingButton)
                    self.tableView.reloadData()
                    Utilities.hideHUD()
                })
            }
        })
    }

}
