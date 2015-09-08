//
//  NewProfileViewController.swift
//  Horoscopes
//
//  Created by Dang Doan on 8/26/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

enum ProfileType {
    case CurrentUser
    case OtherUser
}

class NewProfileViewController: ViewControllerWithAds, UITableViewDataSource, UITableViewDelegate, PostTableViewCellDelegate, FollowTableViewCellDelegate, UISearchBarDelegate, SearchViewControllerDelegate {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var profileView: UIView!
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
    @IBOutlet weak var navigationViewHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var newsfeedFollowButton: UIButton!
    
    var loginView: UIView!
    
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
    var isFirstDataLoad = true
    var filteredResult = [String]()
    var noPost = true
    var noFollowingUser = true
    var noFollower = true
    var postTypeText = [
        "How do you feel today?",
        "Share your story",
        "What's on your mind"
    ]
    var postTypeImage = [
        "newfeeds_post_feel",
        "newfeeds_post_story",
        "newfeeds_post_mind"
    ]
    var friends = [UserProfile]()
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if profileType == .CurrentUser {
            navigationView.subviews.map({ $0.removeFromSuperview() })
            navigationViewHeightLayoutConstraint.constant = 0
            newsfeedFollowButton.removeFromSuperview()
        } else {
            searchButton.removeFromSuperview()
            let textField = searchBar.valueForKey("searchField") as! UITextField
            textField.textColor = UIColor.whiteColor()
            searchBar.placeholder = "\(userProfile.name)"
            if XAppDelegate.currentUser.uid != -1 {
                if userProfile.uid != XAppDelegate.currentUser.uid {
                    SocialManager.sharedInstance.isFollowing(userProfile.uid, followerId: XAppDelegate.currentUser.uid, completionHandler: { (result, error) -> Void in
                        if let error = error {
                            
                        } else {
                            if result!["isfollowing"] as! Int != 1 {
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    self.newsfeedFollowButton.hidden = false
                                })
                            } else {
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    self.newsfeedFollowButton.removeFromSuperview()
                                })
                            }
                        }
                    })
                }
            }
        }
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if !isFirstDataLoad {
            switch currentTab {
            case .Post:
                getUserPosts(nil)
            case .Following:
                getFollowingUsers(nil)
            case .Followers:
                let group = dispatch_group_create()
                getFollowingUsers(group)
                getFollowers(group)
                dispatch_group_notify(group, dispatch_get_main_queue(), { () -> Void in
                    self.checkFollowStatus()
                    self.tableView.reloadData()
                })
            }
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
    
    // MARK: - Configure UI
    
    func configureTableHeaderView(title: String) {
        if tableView.tableHeaderView == nil {            let view = UIView(frame: CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.frame.width, height: 64))
            let label = UILabel()
            label.tag = 1
            label.text = title
            label.textColor = UIColor.grayColor()
            label.font = UIFont.systemFontOfSize(11)
            label.numberOfLines = 0
            view.addSubview(label)
            label.sizeToFit()
            label.frame.origin = CGPoint(x: view.frame.origin.x + 15, y: view.frame.height/2 - label.frame.height/2)
            label.frame.size.width = view.frame.width - 15*2
            tableView.tableHeaderView = view
        } else {
            if let label = tableView.tableHeaderView?.viewWithTag(1) as? UILabel {
                label.text = title
            }
        }
    }
    
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
            changeToWhiteTableViewLayout()
        } else {
            changeToClearTableViewLayout()
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
        profileView.hidden = true
        
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
        cell.configureUserPostUi()
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
    
    func configureFollowTableViewCell(cell: FollowTableViewCell, profile: UserProfile, showFollowButton: Bool) {
        cell.configureFollowButton(profile.isFollowed, showFollowButton: showFollowButton)
        cell.profileNameLabel.text = profile.name
        cell.horoscopeSignLabel.text = profile.horoscopeSignString
        Utilities.getImageFromUrlString(profile.imgURL, completionHandler: { (image) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                cell.profileImageView?.image = image
            })
        })
    }
    
    // MARK: - Action
    
    @IBAction func tapNewsfeedFollowButton(sender: UIButton) {
        Utilities.showHUD()
        SocialManager.sharedInstance.follow(userProfile.uid, completionHandler: { (error) -> Void in
            if let error = error {
                Utilities.showAlert(self, title: "Server Error", message: "There is an error on server. Please try again later.", error: error)
                Utilities.hideHUD()
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.newsfeedFollowButton.removeFromSuperview()
                    Utilities.hideHUD()
                })
            }
        })
    }
    
    @IBAction func tapBackButton(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    @IBAction func tapPostButton(sender: UIButton) {
        currentTab = .Post
        highlightTabButton(sender)
        updateTableView()
        tableView.reloadData()
        getUserPosts(nil)
    }
    
    @IBAction func tapFollowingButton(sender: UIButton) {
        currentTab = .Following
        highlightTabButton(sender)
        updateTableView()
        tableView.reloadData()
        getFollowingUsers(nil)
    }
    
    @IBAction func tapFollowersButton(sender: UIButton) {
        currentTab = .Followers
        highlightTabButton(sender)
        updateTableView()
        tableView.reloadData()
        getFollowers(nil)
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
                        self.profileView.hidden = false
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
        isFirstDataLoad = false
        Utilities.showHUD()
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.configureProfileView()
            self.configureTabButton()
            self.configureTableView()
            let group = dispatch_group_create()
            
            self.getUserPosts(group)
            self.getFollowers(group)
            self.getFollowingUsers(group)
            self.getFriends(group)
            
            dispatch_group_notify(group, dispatch_get_main_queue()) { () -> Void in
                self.checkFollowStatus()
                self.tableView.reloadData()
                self.tableView.hidden = false
                Utilities.hideHUD()
            }
        })
    }
    
    func getFriends(group: dispatch_group_t?) {
        if let group = group {
            dispatch_group_enter(group)
        }
        SocialManager.sharedInstance.retrieveFriendList { (result, error) -> Void in
            if let error = error {
                
            } else {
                self.friends = result!
            }
            if let group = group {
                dispatch_group_leave(group)
            }
        }
    }
    
    func getUserPosts(group: dispatch_group_t?) {
        if let group = group {
            dispatch_group_enter(group)
        }
        SocialManager.sharedInstance.getUserFeed(userProfile.uid, completionHandler: { (result, error) -> Void in
            if let error = error {
                
            } else {
                self.handleData(group, oldData: &self.userPosts, newData: result!, button: self.postButton)
            }
            if let group = group {
                dispatch_group_leave(group)
            }
        })
    }
    
    func getFollowers(group: dispatch_group_t?) {
        if let group = group {
            dispatch_group_enter(group)
        }
        if profileType == .CurrentUser {
            SocialManager.sharedInstance.getCurrentUserFollowersProfile { (result, error) -> Void in
                if let error = error {
                    
                } else {
                    self.handleData(group, oldData: &self.followers, newData: result!, button: self.followersButton)
                }
                if let group = group {
                    dispatch_group_leave(group)
                }
            }
        } else {
            SocialManager.sharedInstance.getOtherUserFollowersProfile(userProfile.uid, completionHandler: { (result, error) -> Void in
                if let error = error {
                    
                } else {
                    self.handleData(group, oldData: &self.followers, newData: result!, button: self.followersButton)
                }
                if let group = group {
                    dispatch_group_leave(group)
                }
            })
        }
    }
    
    func getFollowingUsers(group: dispatch_group_t?) {
        if let group = group {
            dispatch_group_enter(group)
        }
        if profileType == .CurrentUser {
            SocialManager.sharedInstance.getCurrentUserFollowingProfile { (result, error) -> Void in
                if let error = error {
                    
                } else {
                    self.handleData(group, oldData: &self.followingUsers, newData: result!, button: self.followingButton)
                }
                if let group = group {
                    dispatch_group_leave(group)
                }
            }
        } else {
            SocialManager.sharedInstance.getOtherUserFollowingProfile(userProfile.uid, completionHandler: { (result, error) -> Void in
                if let error = error {
                    
                } else {
                    self.handleData(group, oldData: &self.followingUsers, newData: result!, button: self.followingButton)
                }
                if let group = group {
                    dispatch_group_leave(group)
                }
            })
        }
    }
    
    // MARK: - Helper
    
    func changeToClearTableViewLayout() {
        if tableViewLeadingSpaceLayoutConstraint.constant != 0 {
            tableViewLeadingSpaceLayoutConstraint.constant = 0
            tableViewTrailingSpaceLayoutConstraint.constant = 0
            tableViewBottomSpaceLayoutConstraint.constant = 0
            tableView.backgroundColor = UIColor.clearColor()
            tableView.separatorStyle = .None
        }
    }
    
    func changeToWhiteTableViewLayout() {
        if tableViewLeadingSpaceLayoutConstraint.constant == 0 {
            tableViewLeadingSpaceLayoutConstraint.constant = 10
            tableViewTrailingSpaceLayoutConstraint.constant = 10
            tableViewBottomSpaceLayoutConstraint.constant = 8
            tableView.backgroundColor = UIColor.whiteColor()
            tableView.separatorStyle = .SingleLine
        }
    }
    
    func handleData<T: SequenceType>(group: dispatch_group_t?, inout oldData: T, newData: T, button: UIButton) {
        if self.isDataUpdated(oldData, newData: newData) {
            oldData = newData
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.setTabButtonTitleLabel(button)
                if group == nil {
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    func isDataUpdated<T: SequenceType>(oldData: T, newData: T) -> Bool {
        let oldDataIdSet = getDataIds(oldData)
        let newDataIdSet = getDataIds(newData)
        return oldDataIdSet != newDataIdSet
    }
    
    func getDataIds<T: SequenceType>(data: T) -> Set<String> {
        var result = Set<String>()
        for item in data {
            if let post = item as? UserPost {
                result.insert(post.post_id)
            } else if let profile = item as? UserProfile {
                result.insert("\(profile.uid)")
            }
        }
        return result
    }
    
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
    
    // MARK: - Table view data source and delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentTab {
        case .Post:
            if profileType == .CurrentUser {
                if userPosts.count == 0 {
                    noPost = true
                    changeToWhiteTableViewLayout()
                    tableView.separatorStyle = .None
                    configureTableHeaderView("You have not posted anything. Start posting something!")
                    return 3
                } else {
                    noPost = false
                    changeToClearTableViewLayout()
                    tableView.separatorStyle = .SingleLine
                }
            }
            if tableView.tableHeaderView != nil {
                tableView.tableHeaderView = nil
            }
            return userPosts.count
        case .Following:
            if profileType == .CurrentUser {
                if followingUsers.count == 0 {
                    noFollowingUser = true
                    configureTableHeaderView("You have not followed anyone. Start follow someone!")
                    return friends.count
                } else {
                    noFollowingUser = false
                }
            }
            if tableView.tableHeaderView != nil {
                tableView.tableHeaderView = nil
            }
            return followingUsers.count
        case .Followers:
            if profileType == .CurrentUser {
                if followers.count == 0 {
                    noFollower = true
                    configureTableHeaderView("You do not have any follower.")
                    return 0
                } else {
                    noFollower = false
                }
            }
            if tableView.tableHeaderView != nil {
                tableView.tableHeaderView = nil
            }
            return followers.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch currentTab {
        case .Post:
            if profileType == .CurrentUser {
                if noPost {
                    let cell = tableView.dequeueReusableCellWithIdentifier("BasicTableViewCell", forIndexPath: indexPath) as! UITableViewCell
                    cell.textLabel?.text = postTypeText[indexPath.row]
                    cell.textLabel?.textColor = UIColor.grayColor()
                    cell.imageView?.image = UIImage(named: postTypeImage[indexPath.row])
                    return cell
                }
            }
            let post = userPosts[indexPath.row]
            let cell = tableView.dequeueReusableCellWithIdentifier("PostTableViewCell", forIndexPath: indexPath) as! PostTableViewCell
            cell.delegate = self
            configurePostTableViewCell(cell, post: post)
            return cell
        case .Following:
            let cell = tableView.dequeueReusableCellWithIdentifier("FollowTableViewCell", forIndexPath: indexPath) as! FollowTableViewCell
            cell.delegate = self
            if profileType == .CurrentUser {
                if noFollowingUser {
                    let profile = friends[indexPath.row]
                    configureFollowTableViewCell(cell, profile: profile, showFollowButton: true)
                    return cell
                }
            }
            let profile = followingUsers[indexPath.row]
            configureFollowTableViewCell(cell, profile: profile, showFollowButton: false)
            return cell
        case .Followers:
            let cell = tableView.dequeueReusableCellWithIdentifier("FollowTableViewCell", forIndexPath: indexPath) as! FollowTableViewCell
            cell.delegate = self
            let profile = followers[indexPath.row]
            if profileType == .CurrentUser {
                configureFollowTableViewCell(cell, profile: profile, showFollowButton: true)
            } else {
                configureFollowTableViewCell(cell, profile: profile, showFollowButton: false)
            }
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if currentTab != .Post {
            return 70
        } else if noPost {
            if profileType == .CurrentUser {
                return 64
            }
        }
        return UITableViewAutomaticDimension
    }
    
    // MARK: - Delegate
    
    func didChooseUser(profile: UserProfile) {
        let controller = storyboard?.instantiateViewControllerWithIdentifier("NewProfileViewController") as! NewProfileViewController
        controller.profileType = ProfileType.OtherUser
        controller.userProfile = profile
        presentedViewController?.dismissViewControllerAnimated(false, completion: { () -> Void in
            navigationController?.pushViewController(controller, animated: true)
        })
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        let controller = storyboard?.instantiateViewControllerWithIdentifier("SearchViewController") as! SearchViewController
        controller.delegate = self
        navigationController?.presentViewController(controller, animated: true, completion: nil)
    }
    
    func didTapFollowProfile(cell: FollowTableViewCell) {
        let index = tableView.indexPathForCell(cell)?.row
        var profile: UserProfile!
        if currentTab == .Following {
            if noFollowingUser {
                profile = friends[index!]
            } else {
                profile = followingUsers[index!]
            }
        } else {
            profile = followers[index!]
        }
        let controller = storyboard?.instantiateViewControllerWithIdentifier("NewProfileViewController") as! NewProfileViewController
        controller.profileType = ProfileType.OtherUser
        controller.userProfile = profile!
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func didTapShareButton(cell: PostTableViewCell) {
        let index = tableView.indexPathForCell(cell)?.row
        let name = userProfile.name
        let postContent = userPosts[index!].message
        let sharingText = String(format: "%@ \n %@", name, postContent)
        let controller = Utilities.shareViewControllerForType(ShareViewType.ShareViewTypeHybrid, shareType: ShareType.ShareTypeNewsfeed, sharingText: sharingText)
        Utilities.presentShareFormSheetController(self, shareViewController: controller)
    }

    func didTapFollowButton(cell: FollowTableViewCell) {
        let index = tableView.indexPathForCell(cell)?.row
        var uid = -1
        if currentTab == .Followers {
            uid = followers[index!].uid
        } else {
            uid = friends[index!].uid
        }
        Utilities.showHUD()
        SocialManager.sharedInstance.follow(uid, completionHandler: { (error) -> Void in
            if let error = error {
                
            } else {
                let group = dispatch_group_create()
                self.getFollowingUsers(group)
                dispatch_group_notify(group, dispatch_get_main_queue(), { () -> Void in
                    self.checkFollowStatus()
                    self.setTabButtonTitleLabel(self.followingButton)
                    self.tableView.reloadData()
                    Utilities.hideHUD()
                })
            }
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "searchFriend" {
            let controller = segue.destinationViewController as! SearchViewController
            controller.delegate = self
        }
    }

}
